#!/usr/bin/env bash

#
# Helper script to create a local Kubernetes cluster using Kind.
# The script will create a single node Kind cluster and map ports 80 and 443 and install ingress-nginx. Optionally,
# it will create secrets for the poolparty and graphdb license.
#
# The following environment variables are supported:
# KIND_CLUSTER_NAME: change the cluster name, default kind.
# GRAPHDB_LICENSE: path a graphdb license file, that will be used for the graphdb license secret (optional)
# POOLPARTY_LICENSE: path a poolparty license file, that will be used for the poolparty license secret (optional)
#

set -eu

cat <<EOF | kind create cluster --name "${KIND_CLUSTER_NAME:-kind}" --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
    image: kindest/node:v1.36.1@sha256:3489c7674813ba5d8b1a9977baea8a6e553784dab7b84759d1014dbd78f7ebd5
    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP
      - containerPort: 443
        hostPort: 443
        protocol: TCP
  - role: worker
    image: kindest/node:v1.36.1@sha256:3489c7674813ba5d8b1a9977baea8a6e553784dab7b84759d1014dbd78f7ebd5
  - role: worker
    image: kindest/node:v1.36.1@sha256:3489c7674813ba5d8b1a9977baea8a6e553784dab7b84759d1014dbd78f7ebd5
  - role: worker
    image: kindest/node:v1.36.1@sha256:3489c7674813ba5d8b1a9977baea8a6e553784dab7b84759d1014dbd78f7ebd5
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
