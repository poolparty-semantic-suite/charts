# Elasticsearch Upgrade Orchestrator (Kubernetes)

Automates sequential Elasticsearch version upgrades for a StatefulSet-based deployment in Kubernetes. Supports single-node and multi-node cluster deployments, basic auth, pre-upgrade snapshots, and idempotent re-runs.

## Directory structure

```
scripts/elasticsearch/
  upgrade-elasticsearch.sh      # orchestrator — entry point
  lib.sh                        # shared curl/auth/health helpers
  migrations/
    8.19.13/
      is-migrated.sh            # exits 0 if this version is already applied
      pre-upgrade.sh            # runs against the old node before restart
      post-upgrade.sh           # runs against the new node after restart
    9.2.5/
      is-migrated.sh
      pre-upgrade.sh
      post-upgrade.sh
    9.3.3/
      is-migrated.sh
      pre-upgrade.sh
      post-upgrade.sh
```

Each migration directory also stores a `.done` sentinel file once its post-upgrade script completes successfully.

## Prerequisites

- kubectl configured and pointed at the target cluster
- bash 3.2+, curl, awk, sort (all standard on macOS and Linux)
- Elasticsearch reachable from where the script runs (see [Connecting to Elasticsearch](#connecting-to-elasticsearch))
- The Elasticsearch StatefulSet must use `updateStrategy.type: RollingUpdate` (the default)

## Connecting to Elasticsearch

The script talks to ES over HTTP. If ES is only accessible inside the cluster, set up a port-forward before running:

```sh
kubectl port-forward svc/elasticsearch 9200:9200 &
# Then run the script with the default POOLPARTY_INDEX_URL=http://localhost:9200
```

Alternatively, if running the script from a pod inside the cluster (e.g., a Job), point `POOLPARTY_INDEX_URL` at the in-cluster Service DNS name:

```sh
POOLPARTY_INDEX_URL=http://elasticsearch.default.svc.cluster.local:9200 \
  ./scripts/elasticsearch/upgrade-elasticsearch.sh --to 9.3.3
```

## Quick start

```sh
# Upgrade to 9.3.3 from the version currently in the StatefulSet image tag (auto-detected)
./scripts/elasticsearch/upgrade-elasticsearch.sh --to 9.3.3

# Explicit from/to — useful when resuming a partial upgrade
./scripts/elasticsearch/upgrade-elasticsearch.sh --from 8.17.6 --to 9.3.3

# Single hop only
./scripts/elasticsearch/upgrade-elasticsearch.sh --from 8.17.6 --to 8.19.13

# Take a snapshot before each version step
./scripts/elasticsearch/upgrade-elasticsearch.sh --to 9.3.3 --snapshot
```

## Environment variables

All variables are optional unless marked required.

| Variable | Default | Description |
|---|---|---|
| `POOLPARTY_INDEX_URL` | `http://localhost:9200` | Elasticsearch base URL |
| `POOLPARTY_INDEX_USERNAME` | _(empty)_ | Basic auth username |
| `POOLPARTY_INDEX_PASSWORD` | _(empty)_ | Basic auth password |
| `ES_SECRET_NAME` | _(empty)_ | Name of a K8s Secret containing ES credentials (keys: `username`, `password`) |
| `ES_STATEFULSET` | `elasticsearch` | Name of the Elasticsearch StatefulSet |
| `ES_CONTAINER` | `elasticsearch` | Name of the ES container within the StatefulSet pod spec |
| `KUBENAMESPACE` | current kubectl context namespace | Kubernetes namespace |
| `SNAPSHOT_REPO` | `backup` | Name of an existing ES snapshot repository (required with `--snapshot`) |
| `HEALTH_TIMEOUT` | `300` | Seconds to wait for cluster health after a restart (also used by post-upgrade scripts) |
| `SHARD_DRAIN_TIMEOUT` | `600` | Seconds to wait for primary shards to drain from a pod before restarting it |
| `NODE_REJOIN_TIMEOUT` | `120` | Seconds to wait for a pod to become Ready and rejoin the cluster after restart |

A value set in the shell always takes precedence over one read from a Kubernetes Secret.

## Single-node vs cluster

The script detects topology automatically by querying `GET /_cat/nodes` at startup.

**Single-node** — the StatefulSet is updated to the new image and Kubernetes performs a standard rollout (`kubectl rollout status` waits for completion). Cluster health of `yellow` is accepted as the final healthy state.

**Cluster** — the script performs a rolling restart using the StatefulSet partition mechanism:

1. Pauses automatic rollout by setting `updateStrategy.rollingUpdate.partition` to the replica count (no pods update yet).
2. Updates the image in the StatefulSet spec.
3. For each pod from highest ordinal to lowest:
   - Excludes the node from shard allocation (`cluster.routing.allocation.exclude._name`)
   - Waits for all primary shards to migrate off the node (up to 10 minutes)
   - Lowers the partition so this pod restarts with the new image
   - Waits for the pod to become Ready
   - Waits for the ES node to rejoin the cluster
   - Removes the allocation exclusion
   - Waits for `yellow` health before moving to the next pod
4. Resets partition to 0.
5. Waits for `green` health.

### Pod name → ES node name mapping

ES uses the pod hostname as the node name by default. For StatefulSet pods the hostname is the pod name (`elasticsearch-0`, `elasticsearch-1`, etc.). The script validates this mapping before starting any rolling restarts and exits with a clear error listing the discovered node names if there is a mismatch.

If your ES configuration overrides `node.name` explicitly, set `ES_STATEFULSET` to a value whose derived pod names match the actual ES node names, or align them in your ES config.

## Basic auth

If `xpack.security.enabled=true` is set in the ES configuration, all API calls require credentials.

```sh
# Via environment variables
POOLPARTY_INDEX_USERNAME=elastic POOLPARTY_INDEX_PASSWORD=secret \
  ./scripts/elasticsearch/upgrade-elasticsearch.sh --to 9.3.3

# Via a Kubernetes Secret (keys must be "username" and "password")
kubectl create secret generic es-credentials \
  --from-literal=username=elastic \
  --from-literal=password=secret

ES_SECRET_NAME=es-credentials \
  ./scripts/elasticsearch/upgrade-elasticsearch.sh --to 9.3.3
```

All curl calls — in the orchestrator and in every migration script — pick up credentials automatically through `lib.sh`.

## Snapshots

Pass `--snapshot` to take a snapshot before each version step. The repository must already exist in Elasticsearch before the script runs — the script will not create it.

```sh
# Verify your repo exists
curl http://localhost:9200/_snapshot/backup

# Run with snapshots
SNAPSHOT_REPO=backup ./scripts/elasticsearch/upgrade-elasticsearch.sh --to 9.3.3 --snapshot
```

Snapshots are named `pre-upgrade-to-<version>-<timestamp>` and polled until `SUCCESS` (30-minute timeout). A `FAILED` or `PARTIAL` result aborts the upgrade before any image changes are made.

## How idempotency works

Each migration step is guarded by `is-migrated.sh`, which:

1. Checks for a `.done` sentinel file in the migration directory
2. If the file is absent, queries the live ES version — if it is already at or past the target version, writes the sentinel and exits 0

This means re-running the script after a partial failure skips any version steps that completed successfully and resumes from where it stopped.

## Adding a new upgrade path

1. Create `migrations/<target-version>/` with three executable scripts:

   **`is-migrated.sh`** — exits 0 if the migration is already applied:
   ```sh
   cp -r migrations/9.3.3 migrations/<new-version>
   # Update MARKER path, TARGET version, and .done text
   ```

   **`pre-upgrade.sh`** — runs against the current (old) node. Typical tasks: check deprecation warnings, disable shard allocation, flush indices.

   **`post-upgrade.sh`** — runs against the new node after it is healthy. Typical tasks: re-enable allocation, verify index health, write `.done`.

2. Add the new version to `KNOWN_VERSIONS` in `upgrade-elasticsearch.sh` in ascending order:
   ```sh
   KNOWN_VERSIONS=("8.19.13" "9.2.5" "9.3.3" "<new-version>")
   ```

## Troubleshooting

**`StatefulSet 'elasticsearch' not found`**
The script cannot find the StatefulSet. Verify the name and namespace:
```sh
kubectl get statefulsets -n <namespace>
ES_STATEFULSET=<actual-name> KUBENAMESPACE=<namespace> ./scripts/elasticsearch/upgrade-elasticsearch.sh --to 9.3.3
```

**`Connection refused` at startup**
Elasticsearch is not reachable. If running outside the cluster, start a port-forward:
```sh
kubectl port-forward svc/elasticsearch 9200:9200
```

**`Elasticsearch returned an HTTP error` (curl exit 22)**
Usually a 401 Unauthorized when security is enabled without credentials configured. Set `POOLPARTY_INDEX_USERNAME` and `POOLPARTY_INDEX_PASSWORD` (or `ES_SECRET_NAME`).

**`No ES node named 'elasticsearch-0' found`**
The pod name does not match the ES node name. Check the actual node names:
```sh
curl http://localhost:9200/_cat/nodes?h=name
```
Then either set `ES_STATEFULSET` to match the actual pod name prefix, or align `node.name` in your ES configuration.

**`Primary shards did not drain from 'elasticsearch-N'`**
Shard drain timed out (10 minutes). The cluster may be undersized to absorb the primary shards of the excluded pod. Check cluster state:
```sh
curl http://localhost:9200/_cluster/health
curl "http://localhost:9200/_cat/shards?h=index,shard,prirep,state,node&v"
```

**`critical deprecation(s) found` during 9.x pre-upgrade**
The running 8.x instance has breaking-change deprecations that must be resolved before the 8→9 jump:
```sh
curl http://localhost:9200/_migration/deprecations | python3 -m json.tool
```

**Re-running after partial failure**
The script is safe to re-run. Completed steps are skipped via `.done` files. To force a step to re-run, delete the corresponding sentinel:
```sh
rm scripts/elasticsearch/migrations/<version>/.done
```

**Partition left non-zero after a failed run**
The script's EXIT trap resets the partition to 0 automatically on failure. If the process was killed with `SIGKILL` (e.g. `kill -9`) the trap cannot run; reset it manually:
```sh
kubectl patch statefulset elasticsearch -n <namespace> --type=merge \
  -p '{"spec":{"updateStrategy":{"rollingUpdate":{"partition":0}}}}'
```
