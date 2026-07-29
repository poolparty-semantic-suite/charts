#!/usr/bin/env bash

#
# Helper script to create a local Kubernetes cluster using Kind.
# The script will create a single node Kind cluster and map ports 80 and 443 and install ingress-nginx. Optionally,
# it will create secrets for the Graph Modeling and GraphDB licenses.
#
# The following environment variables are supported:
# KIND_CLUSTER_NAME: change the cluster name, default kind.
# GRAPHDB_LICENSE: path a GraphDB license file, that will be used for the graphdb-license secret (optional)
# GRAPH_MODELING_LICENSE: path a Graph Modeling license file, that will be used for the graph-modeling-license secret (optional)
#

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

if [ -n "${GRAPH_MODELING_LICENSE:-}" ]; then
  kubectl create secret generic graph-modeling-license --from-file graph-modeling.key="$GRAPH_MODELING_LICENSE"
fi
