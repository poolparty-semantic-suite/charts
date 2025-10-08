# Elasticsearch Examples

The current directory contains examples of a resources, which can be used to install Elasticsearch instance or a cluster
of instances via the EKC Operator that is present in the Graphwise Platform Helm Chart.

## Quickstart

The [quickstart.yaml](quickstart.yaml) is a specification that starts a single node of Elasticsearch with minimal
configuration.

When created in Kubernetes, the EKC Operator will automatically pick it up and install the Elasticsearch instance.

You can add the resource by using the Kubernetes CLI or updating the chart with included resources as templates.

**Example using kubectl**

```shell
cat <<EOF | kubectl apply -n my-namespace -f -
apiVersion: elasticsearch.k8s.elastic.co/v1
kind: Elasticsearch
metadata:
  name: graphwise-platform
spec:
  version: 8.17.6
  image: docker.io/ontotext/poolparty-elasticsearch:8.17.6
  nodeSets:
  - name: master
    count: 1
    config:
      node.store.allow_mmap: false
      xpack.security.enabled: false
EOF
```

The security is disabled using the `xpack.security.enabled: false` configuration in order to ease the access and further
access configurations for other components and services.

It can be used as starting point for trying out the Graphwise Platform or quick prototyping. We recommend using the
`quickstart` for local deployments or experiments in order to achieve specific use case or scenario.

## Elasticsearch

The [elasticsearch.yaml](elasticsearch.yaml) contains more complete specification of the Elasticsearch cluster that can
be used in a standard setup.

When created in Kubernetes, the operator will install one master node and two data nodes of Elasticsearch.

TBD: more info on the deployment and the references to the Elasticsearch documentation.
