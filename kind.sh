#!/usr/bin/env bash

set -eu

cat <<EOF | kind create cluster --name "${KIND_CLUSTER_NAME:-kind}" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  extraPortMappings:
  - containerPort: 80
    hostPort: 80
    protocol: TCP
  - containerPort: 443
    hostPort: 443
    protocol: TCP
EOF

kubectl apply -f https://kind.sigs.k8s.io/examples/ingress/deploy-ingress-nginx.yaml

while ! kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s &> /dev/null; do

    echo "waiting for nginx ingress controller"
    sleep 5
done

if [ -n "${GRAPHDB_LICENSE:-}" ]; then
  kubectl create secret generic graphdb-license --from-file graphdb.license="$GRAPHDB_LICENSE"
fi

if [ -n "${POOLPARTY_LICENSE:-}" ]; then
  kubectl create secret generic poolparty-license --from-file poolparty.key="$POOLPARTY_LICENSE"
fi
