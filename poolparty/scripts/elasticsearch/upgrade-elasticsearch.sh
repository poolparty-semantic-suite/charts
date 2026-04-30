#!/usr/bin/env bash
set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────

ES_URL="${POOLPARTY_INDEX_URL:-http://localhost:9200}"
ES_STATEFULSET="${ES_STATEFULSET:-elasticsearch}"
ES_CONTAINER="${ES_CONTAINER:-elasticsearch}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MIGRATIONS_DIR="$SCRIPT_DIR/migrations"
SNAPSHOT_REPO="${SNAPSHOT_REPO:-backup}"
KNOWN_VERSIONS=("8.19.13" "9.2.5" "9.3.3")

# Namespace: prefer explicit env override, then current kubectl context, then "default"
NAMESPACE="${KUBENAMESPACE:-$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null || true)}"
NAMESPACE="${NAMESPACE:-default}"

# Timeout overrides (seconds)
SHARD_DRAIN_TIMEOUT="${SHARD_DRAIN_TIMEOUT:-600}"
HEALTH_TIMEOUT="${HEALTH_TIMEOUT:-300}"
NODE_REJOIN_TIMEOUT="${NODE_REJOIN_TIMEOUT:-120}"

# ── Bootstrap: credentials ────────────────────────────────────────────────────
# Credentials are read from a Kubernetes Secret when ES_SECRET_NAME is set.
# Expected secret keys: "username" and "password".
# A value already present in the environment always takes precedence.

if [[ -n "${ES_SECRET_NAME:-}" ]]; then
    _k8s_secret_val() {
        kubectl get secret "$ES_SECRET_NAME" --namespace "$NAMESPACE" \
            -o "jsonpath={.data.$1}" 2>/dev/null | base64 -d 2>/dev/null || true
    }
    : "${POOLPARTY_INDEX_USERNAME:=$(_k8s_secret_val username)}"
    : "${POOLPARTY_INDEX_PASSWORD:=$(_k8s_secret_val password)}"
fi
export POOLPARTY_INDEX_USERNAME POOLPARTY_INDEX_PASSWORD

# shellcheck source=lib.sh
source "$SCRIPT_DIR/lib.sh"

# ── Utilities ─────────────────────────────────────────────────────────────────

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }
die() { log "ERROR: $*" >&2; exit 1; }

# ── StatefulSet helpers ───────────────────────────────────────────────────────

_k8s_current_image() {
    kubectl get statefulset "$ES_STATEFULSET" \
        --namespace "$NAMESPACE" \
        -o "jsonpath={.spec.template.spec.containers[?(@.name==\"${ES_CONTAINER}\")].image}" \
        2>/dev/null || true
}

set_image_in_statefulset() {
    local new_image="$1"
    kubectl set image statefulset/"$ES_STATEFULSET" \
        --namespace "$NAMESPACE" \
        "${ES_CONTAINER}=${new_image}" \
        > /dev/null \
        || die "Failed to update image to '$new_image' in StatefulSet '$ES_STATEFULSET'"
}

# ── Health helpers ────────────────────────────────────────────────────────────

wait_for_healthy() {
    local required="${1:-${EXPECTED_HEALTH_STATUS:-yellow}}"
    local deadline=$((SECONDS + HEALTH_TIMEOUT))
    log "Waiting for cluster health: $required or better (timeout: ${HEALTH_TIMEOUT}s)..."
    while [[ $SECONDS -lt $deadline ]]; do
        local status
        status=$(curl -sf --connect-timeout 10 "${_ES_CURL_AUTH[@]:+${_ES_CURL_AUTH[@]}}" \
            "$ES_URL/_cluster/health" 2>/dev/null \
            | grep -o '"status":"[^"]*"' | head -1 | cut -d'"' -f4 || true)
        health_ok "$status" "$required" && { log "Cluster health: $status"; return 0; }
        sleep 5
    done
    echo "ERROR: Elasticsearch did not reach '$required' health within ${HEALTH_TIMEOUT}s." >&2
    echo "  → Status:  kubectl get pods -n $NAMESPACE" >&2
    echo "  → Logs:    kubectl logs ${ES_STATEFULSET}-0 -n $NAMESPACE" >&2
    echo "  → Check:   $ES_URL/_cluster/health" >&2
    exit 1
}

# ── Pod readiness ─────────────────────────────────────────────────────────────

wait_for_pod_ready() {
    local pod_name="$1" expected_image="$2"
    local deadline=$((SECONDS + NODE_REJOIN_TIMEOUT))
    local expected_tag="${expected_image##*:}"
    log "Waiting for pod '$pod_name' to be Ready with image tag :${expected_tag} (timeout: ${NODE_REJOIN_TIMEOUT}s)..."
    while [[ $SECONDS -lt $deadline ]]; do
        local ready running_image
        ready=$(kubectl get pod "$pod_name" --namespace "$NAMESPACE" \
            -o 'jsonpath={.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || true)
        running_image=$(kubectl get pod "$pod_name" --namespace "$NAMESPACE" \
            -o 'jsonpath={.status.containerStatuses[0].image}' 2>/dev/null || true)
        # Compare only the tag — Kubernetes may prepend "docker.io/" to the repo
        [[ "$ready" == "True" && "${running_image##*:}" == "$expected_tag" ]] \
            && { log "Pod '$pod_name' is Ready"; return 0; }
        sleep 5
    done
    die "Pod '$pod_name' did not become Ready within ${NODE_REJOIN_TIMEOUT}s
  → Describe: kubectl describe pod $pod_name -n $NAMESPACE
  → Logs:     kubectl logs $pod_name -n $NAMESPACE"
}

# ── Cluster rolling-restart helpers ───────────────────────────────────────────

# Tracks which nodes we have excluded so undrain removes only the target node
# rather than clearing all exclusions globally.
_EXCLUDED_NODES=()

_sync_allocation_exclusions() {
    local value
    if [[ ${#_EXCLUDED_NODES[@]} -eq 0 ]]; then
        value='null'
    else
        local list
        list=$(IFS=','; printf '%s' "${_EXCLUDED_NODES[*]}")
        value="\"${list}\""
    fi
    local response
    response=$(es_curl "/_cluster/settings" \
        -X PUT -H 'Content-Type: application/json' \
        -d "{\"transient\":{\"cluster.routing.allocation.exclude._name\":${value}}}")
    echo "$response" | grep -q '"acknowledged":true' \
        || { echo "ERROR: Failed to sync shard allocation exclusions." >&2; exit 1; }
}

drain_node() {
    local node_name="$1"
    _EXCLUDED_NODES+=("$node_name")
    _sync_allocation_exclusions
    log "Node '$node_name' excluded from shard allocation"
}

undrain_node() {
    local node_name="$1"
    local remaining=()
    if [[ ${#_EXCLUDED_NODES[@]} -gt 0 ]]; then
        for n in "${_EXCLUDED_NODES[@]}"; do
            [[ "$n" != "$node_name" ]] && remaining+=("$n")
        done
    fi
    _EXCLUDED_NODES=("${remaining[@]:+${remaining[@]}}")
    _sync_allocation_exclusions
    log "Node '$node_name' re-included in shard allocation"
}

wait_for_shards_drained() {
    local node_name="$1"
    local deadline=$((SECONDS + SHARD_DRAIN_TIMEOUT))
    log "Waiting for primary shards to drain from '$node_name' (timeout: ${SHARD_DRAIN_TIMEOUT}s)..."
    while [[ $SECONDS -lt $deadline ]]; do
        local count
        count=$(curl -sf --connect-timeout 10 "${_ES_CURL_AUTH[@]:+${_ES_CURL_AUTH[@]}}" \
            "$ES_URL/_cat/shards?h=node,prirep" 2>/dev/null \
            | awk -v n="$node_name" '$1 == n && $2 == "p" {c++} END {print c+0}') \
            || count=1  # Treat unreachable ES as "not drained yet" rather than aborting
        [[ "$count" -eq 0 ]] && return 0
        log "  $count primary shard(s) still on '$node_name'..."
        sleep 10
    done
    die "Primary shards did not drain from '$node_name' within ${SHARD_DRAIN_TIMEOUT}s"
}

wait_for_node_rejoin() {
    local node_name="$1"
    local deadline=$((SECONDS + NODE_REJOIN_TIMEOUT))
    log "Waiting for node '$node_name' to rejoin (timeout: ${NODE_REJOIN_TIMEOUT}s)..."
    while [[ $SECONDS -lt $deadline ]]; do
        # Exact line match (-x) prevents 'elasticsearch' matching 'elasticsearch-0'
        curl -sf --connect-timeout 10 "${_ES_CURL_AUTH[@]:+${_ES_CURL_AUTH[@]}}" \
            "$ES_URL/_cat/nodes?h=name" 2>/dev/null \
            | grep -qxF "$node_name" \
            && { log "Node '$node_name' has rejoined"; return 0; }
        sleep 5
    done
    die "Node '$node_name' did not rejoin within ${NODE_REJOIN_TIMEOUT}s
  → Logs: kubectl logs $node_name -n $NAMESPACE"
}

validate_node_names() {
    local nodes
    nodes=$(es_curl "/_cat/nodes?h=name")
    local i
    for ((i = 0; i < REPLICA_COUNT; i++)); do
        local pod="${ES_STATEFULSET}-${i}"
        printf '%s\n' "$nodes" | grep -qxF "$pod" && continue
        echo "ERROR: No ES node named '$pod' found in the cluster." >&2
        echo "  → Known nodes: $(printf '%s\n' "$nodes" | tr '\n' ' ')" >&2
        echo "  → ES uses the pod name as node.name for StatefulSet pods." >&2
        echo "  → If node.name is overridden in your ES config, set ES_STATEFULSET" >&2
        echo "    to a value whose pod names match the actual ES node names." >&2
        exit 1
    done
}

# ── Rolling restart ───────────────────────────────────────────────────────────

rolling_restart() {
    local new_image="$1" i

    if [[ "$IS_CLUSTER" == "true" ]]; then
        validate_node_names

        # Pause automatic rollout before changing the image to avoid a race where
        # the StatefulSet controller starts rolling pods before we can control order.
        log "Pausing automatic rollout (partition=${REPLICA_COUNT})..."
        kubectl patch statefulset "$ES_STATEFULSET" \
            --namespace "$NAMESPACE" \
            --type=merge \
            -p "{\"spec\":{\"updateStrategy\":{\"rollingUpdate\":{\"partition\":${REPLICA_COUNT}}}}}" \
            > /dev/null \
            || die "Failed to pause StatefulSet rollout"

        set_image_in_statefulset "$new_image"

        for ((i = REPLICA_COUNT - 1; i >= 0; i--)); do
            local pod="${ES_STATEFULSET}-${i}"
            log "Rolling pod $((REPLICA_COUNT - i))/${REPLICA_COUNT}: $pod"

            drain_node "$pod"
            wait_for_shards_drained "$pod"

            # Lower partition so only this pod updates next
            kubectl patch statefulset "$ES_STATEFULSET" \
                --namespace "$NAMESPACE" \
                --type=merge \
                -p "{\"spec\":{\"updateStrategy\":{\"rollingUpdate\":{\"partition\":${i}}}}}" \
                > /dev/null \
                || die "Failed to lower partition to $i"

            wait_for_pod_ready "$pod" "$new_image"
            wait_for_node_rejoin "$pod"
            undrain_node "$pod"

            [[ $i -gt 0 ]] && wait_for_healthy "yellow"
        done

        # Reset partition (warn on failure — all pods are already updated at this point)
        kubectl patch statefulset "$ES_STATEFULSET" \
            --namespace "$NAMESPACE" \
            --type=merge \
            -p '{"spec":{"updateStrategy":{"rollingUpdate":{"partition":0}}}}' \
            > /dev/null 2>&1 \
            || log "WARNING: Failed to reset partition to 0. Run manually:
  kubectl patch statefulset $ES_STATEFULSET -n $NAMESPACE --type=merge \\
    -p '{\"spec\":{\"updateStrategy\":{\"rollingUpdate\":{\"partition\":0}}}}'"

    else
        set_image_in_statefulset "$new_image"
        kubectl rollout status statefulset/"$ES_STATEFULSET" \
            --namespace "$NAMESPACE" \
            --timeout="${HEALTH_TIMEOUT}s" \
            || die "Rollout of '$ES_STATEFULSET' did not complete within ${HEALTH_TIMEOUT}s
  → Check: kubectl rollout status statefulset/$ES_STATEFULSET -n $NAMESPACE
  → Logs:  kubectl logs ${ES_STATEFULSET}-0 -n $NAMESPACE"
    fi

    # Allocation is still restricted to primaries at this point (post-upgrade.sh re-enables
    # replicas). Only require yellow — all primaries assigned — not green.
    wait_for_healthy "yellow"
}

# ── Snapshot ──────────────────────────────────────────────────────────────────

take_snapshot() {
    local target="$1"
    local name="pre-upgrade-to-${target}-$(date '+%Y%m%d%H%M%S')"

    log "Taking snapshot '$name' in repository '$SNAPSHOT_REPO'..."
    # wait_for_completion=false ensures the response is always {"accepted":true},
    # even on fast/small clusters that would otherwise respond synchronously.
    local response
    response=$(es_curl "/_snapshot/$SNAPSHOT_REPO/$name?wait_for_completion=false" \
        -X PUT -H 'Content-Type: application/json' \
        -d '{"ignore_unavailable":true,"include_global_state":true}')
    echo "$response" | grep -q '"accepted":true' \
        || die "Snapshot '$name' was not accepted — check: kubectl logs ${ES_STATEFULSET}-0 -n $NAMESPACE"

    local deadline=$((SECONDS + 1800))
    local state=""
    while [[ $SECONDS -lt $deadline ]]; do
        state=$(curl -sf --connect-timeout 10 "${_ES_CURL_AUTH[@]:+${_ES_CURL_AUTH[@]}}" \
            "$ES_URL/_snapshot/$SNAPSHOT_REPO/$name" 2>/dev/null \
            | grep -o '"state":"[^"]*"' | head -1 | cut -d'"' -f4 || true)
        case "$state" in
            SUCCESS) log "Snapshot '$name' complete"; return 0 ;;
            FAILED|PARTIAL) die "Snapshot '$name' ended with state '$state' — check: kubectl logs ${ES_STATEFULSET}-0 -n $NAMESPACE" ;;
        esac
        sleep 10
    done
    die "Snapshot '$name' did not complete within 30 minutes"
}

# ── Argument parsing ──────────────────────────────────────────────────────────

FROM_VERSION=""
TO_VERSION=""
SNAPSHOT=false
while [[ $# -gt 0 ]]; do
    case "$1" in
        --from)     FROM_VERSION="$2"; shift 2 ;;
        --to)       TO_VERSION="$2";   shift 2 ;;
        --snapshot) SNAPSHOT=true;     shift   ;;
        *)          die "Unknown argument: $1" ;;
    esac
done

[[ -n "$TO_VERSION" ]] || die "--to <version> is required"

version_known=false
for v in "${KNOWN_VERSIONS[@]}"; do
    [[ "$v" == "$TO_VERSION" ]] && version_known=true && break
done
$version_known || die "Unknown target version '$TO_VERSION' (known: ${KNOWN_VERSIONS[*]})"

# ── Pre-flight ────────────────────────────────────────────────────────────────

kubectl get statefulset "$ES_STATEFULSET" --namespace "$NAMESPACE" > /dev/null 2>&1 || {
    echo "ERROR: StatefulSet '$ES_STATEFULSET' not found in namespace '$NAMESPACE'." >&2
    echo "  → List StatefulSets:   kubectl get statefulsets -n $NAMESPACE" >&2
    echo "  → Override name:       ES_STATEFULSET=<name> $0 ..." >&2
    echo "  → Override namespace:  KUBENAMESPACE=<ns> $0 ..." >&2
    exit 1
}

update_strategy=$(kubectl get statefulset "$ES_STATEFULSET" --namespace "$NAMESPACE" \
    -o jsonpath='{.spec.updateStrategy.type}' 2>/dev/null || true)
update_strategy="${update_strategy:-RollingUpdate}"
[[ "$update_strategy" == "RollingUpdate" ]] \
    || die "StatefulSet '$ES_STATEFULSET' uses updateStrategy '$update_strategy'; only RollingUpdate is supported"

container_check=$(kubectl get statefulset "$ES_STATEFULSET" --namespace "$NAMESPACE" \
    -o "jsonpath={.spec.template.spec.containers[?(@.name==\"${ES_CONTAINER}\")].name}" 2>/dev/null || true)
[[ "$container_check" == "$ES_CONTAINER" ]] \
    || die "Container '$ES_CONTAINER' not found in StatefulSet '$ES_STATEFULSET'
  → Override container name: ES_CONTAINER=<name> $0 ..."

current_image=$(_k8s_current_image)
[[ -n "$current_image" ]] \
    || die "Could not read image from StatefulSet '$ES_STATEFULSET' (container: '$ES_CONTAINER')"
[[ "$current_image" == *:* ]] \
    || die "StatefulSet image '$current_image' has no tag — cannot detect current version; pass --from <version>"

ES_IMAGE_REPO="${current_image%:*}"

REPLICA_COUNT=$(kubectl get statefulset "$ES_STATEFULSET" --namespace "$NAMESPACE" \
    -o jsonpath='{.spec.replicas}' 2>/dev/null || echo "1")
REPLICA_COUNT="${REPLICA_COUNT:-1}"

if [[ -z "$FROM_VERSION" ]]; then
    FROM_VERSION="${current_image##*:}"
    log "Detected current version from StatefulSet image: $FROM_VERSION"
fi

steps=()
_to_major="${TO_VERSION%%.*}"
for v in "${KNOWN_VERSIONS[@]}"; do
    if [[ "$(printf '%s\n' "$FROM_VERSION" "$v" | sort -V | head -1)" == "$v" ]]; then
        continue
    fi
    # Skip same-major intermediaries — versions in the same major as TO are
    # independent targets, not mandatory waypoints (e.g. 9.2.5 is not a required
    # stop on the way to 9.3.3; both are direct upgrade targets from 8.x).
    if [[ "${v%%.*}" == "$_to_major" && "$v" != "$TO_VERSION" ]]; then
        continue
    fi
    steps+=("$v")
    [[ "$v" == "$TO_VERSION" ]] && break
done
[[ ${#steps[@]} -gt 0 ]] || die "No upgrade steps found for $FROM_VERSION → $TO_VERSION"

require_es

node_count=$(curl -sf --connect-timeout 10 "${_ES_CURL_AUTH[@]:+${_ES_CURL_AUTH[@]}}" \
    "$ES_URL/_cat/nodes?h=name" 2>/dev/null | wc -l | tr -d '[:space:]')
node_count="${node_count:-1}"
IS_CLUSTER=false
[[ "$node_count" -gt 1 ]] && IS_CLUSTER=true

if [[ "$IS_CLUSTER" == "true" ]]; then
    log "Topology: cluster ($node_count nodes, $REPLICA_COUNT replica(s))"
else
    log "Topology: single-node"
fi

EXPECTED_HEALTH_STATUS="yellow"
[[ "$IS_CLUSTER" == "true" ]] && EXPECTED_HEALTH_STATUS="green"
export EXPECTED_HEALTH_STATUS

log "Namespace:    $NAMESPACE"
log "StatefulSet:  $ES_STATEFULSET"
log "Image repo:   $ES_IMAGE_REPO"
log "Upgrade path: $FROM_VERSION → $(IFS=' → '; echo "${steps[*]}")"

if $SNAPSHOT; then
    curl -sf --connect-timeout 10 "${_ES_CURL_AUTH[@]:+${_ES_CURL_AUTH[@]}}" "$ES_URL/_snapshot/$SNAPSHOT_REPO" \
        > /dev/null 2>&1 || {
        echo "ERROR: Snapshot repository '$SNAPSHOT_REPO' was not found in Elasticsearch." >&2
        echo "  → Create the repository before running with --snapshot." >&2
        echo "  → Repository name (override with SNAPSHOT_REPO=<name>): $SNAPSHOT_REPO" >&2
        exit 1
    }
    log "Snapshot repository '$SNAPSHOT_REPO' verified"
fi

# ── Main upgrade loop ─────────────────────────────────────────────────────────

for target in "${steps[@]}"; do
    mig_dir="$MIGRATIONS_DIR/$target"
    [[ -d "$mig_dir" ]] || die "Migration directory not found: $mig_dir"

    log "────────────────────────────────────────────"
    log "Step: upgrading to $target"

    if bash "$mig_dir/is-migrated.sh"; then
        log "Already migrated to $target — skipping"
        continue
    fi

    $SNAPSHOT && take_snapshot "$target"

    log "Running pre-upgrade for $target"
    bash "$mig_dir/pre-upgrade.sh" \
        || die "pre-upgrade.sh failed for $target"

    new_image="${ES_IMAGE_REPO}:${target}"
    old_image=$(_k8s_current_image)
    log "Restarting Elasticsearch: $old_image → $new_image"
    # Register a trap to restore the previous image if rolling_restart fails,
    # keeping the StatefulSet spec consistent with what is actually running.
    trap "set_image_in_statefulset '$old_image'; kubectl patch statefulset '$ES_STATEFULSET' --namespace '$NAMESPACE' --type=merge -p '{\"spec\":{\"updateStrategy\":{\"rollingUpdate\":{\"partition\":0}}}}' > /dev/null 2>&1 || true" EXIT

    rolling_restart "$new_image"

    trap - EXIT  # Clear restore trap — restart succeeded

    log "Running post-upgrade for $target"
    bash "$mig_dir/post-upgrade.sh" \
        || die "post-upgrade.sh failed for $target"

    log "Successfully upgraded to $target"
done

log "────────────────────────────────────────────"
log "Upgrade complete. Elasticsearch is now at $TO_VERSION."
