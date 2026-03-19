# Helm Chart for PoolParty

[![CI - Pull Request](https://github.com/poolparty-semantic-suite/charts/actions/workflows/pull-request.yml/badge.svg)](https://github.com/poolparty-semantic-suite/charts/actions/workflows/pull-request.yml)
![Version: 0.2.0](https://img.shields.io/badge/Version-0.2.0-informational?style=flat-square)
![AppVersion: 10.1.0](https://img.shields.io/badge/AppVersion-10.1.0-informational?style=flat-square)

Welcome to the official [Helm](https://helm.sh/) chart repository for [PoolParty](https://www.poolparty.biz/)!
This Helm chart makes it easy to deploy and manage PoolParty on your [Kubernetes](https://kubernetes.io/) cluster.

# About PoolParty

The PoolParty Semantic Suite is a comprehensive middleware software. It includes browser-based taxonomy management,
thesaurus management, linked data frontend, ontology management, corpus management, extractor and a semantic middleware configurator.

# Versioning

The Helm chart follows [Semantic Versioning v2](https://semver.org/) so any breaking changes will be rolled out only in
MAJOR versions of the chart.

Please, always check out the migration guides in [UPGRADE.md](UPGRADE.md), before switching to another major version of
the Helm chart.

The chart has its own version, and it's not the same as the version of PoolParty.
The table bellow highlights the version mapping between the Helm chart and PoolParty.

| Helm chart version | PoolParty version |
|--------------------|-------------------|
| 0.1.x              | 10.0.x            |
| 0.2.x              | 10.1.x            |

# Prerequisites

* Kubernetes v1.30+
* Helm v3.18+
* kubectl

# Installation

## Dependencies

PoolParty depends on several services than need to be installed before PoolParty.

### GraphDB

PoolParty requires at least version 11.1 of GraphDB. To install it, consult the chart for
[GraphDB](https://github.com/Ontotext-AD/graphdb-helm).

The basic steps to install GraphDB using the official Helm chart are:
1. Create a secret with the GraphDB license

    ```shell
    kubectl create secret generic graphdb-license --from-file graphdb.license=/path/to/graphdb.license
    ```

2. Add the Helm repository

    ```shell
    helm repo add ontotext https://maven.ontotext.com/repository/helm-public/
    helm repo update
    ```

3. Install GraphDB

    ```shell
    helm install graphdb ontotext/graphdb
    ```

### Elasticsearch

Elasticsearch instance at version 8.x is required. Additionally, the instance needs to have the
[MAT](https://www.elastic.co/docs/reference/elasticsearch/plugins/mapper-annotated-text) plugin installed.

The [elasticsearch.yaml](examples/dependencies/elasticsearch.yaml) file provides a minimal example to install an
Elasticsearch instance in your cluster. This example uses a Graphwise provided image that has the MAT plugin
pre-installed.

Install this example with:

```shell
kubectl apply --filename examples/dependencies/elasticsearch.yaml
```

> [!CAUTION]
> This example is for development and evaluation purposes only. Consult the official
> [Elasticsearch documentation](https://www.elastic.co/docs/deploy-manage/deploy/cloud-on-k8s) for deploying a
> production grade instance in Kubernetes.

### Keycloak

PoolParty uses a custom image for Keycloak. This image includes Graphwise developed extensions, that make their
integration smoother, as well as a parameterized Keycloak realm json file, that is used when initializing the realm
used by PoolParty.

The [keycloak.yaml](examples/dependencies/keycloak.yaml) file provides a minimal example to install a
Keycloak instance in your cluster. This example uses a Graphwise provided image that has extensions pre-installed.

> [!NOTE]
> The Keycloak address needs to be resolvable from the your browser and from within the cluster. The easiest way to do
> this is to use a service like [nip.io](https://nip.io/), which encodes the IP address for the A record in the FQDN.

Install this example, first determine the IP address of your host machine, and:

```shell
export KEYCLOAK_FQDN="keycloak.[your ip address].nip.io"
sed "s/\[KEYCLOAK_FQDN\]/$KEYCLOAK_FQDN/" examples/dependencies/keycloak.yaml | \
  kubectl apply --filename -
```

> [!CAUTION]
> This example is for development and evaluation purposes only. Consult the official Keycloak Kubernetes getting started
> [guide](https://www.keycloak.org/getting-started/getting-started-kube) and the
> [Keycloak Operator](https://www.keycloak.org/guides#operator) documentation for deploying a production grade
> instance in Kubernetes.

## PoolParty

With all dependencies in place, PoolParty can be installed.

> [!NOTE]
> PoolParty requires a license. You need to obtain a license file before installing.

1. Create a secret for the PoolParty license

    ```shell
    kubectl create secret generic poolparty-license --from-file poolparty.key=/path/to/poolparty.key
    ```

2. Add the PoolParty Helm repository

    ```shell
    helm repo add poolparty-semantic-suite https://poolparty-semantic-suite.github.io/charts
    helm repo update
    ```

3. Install PoolParty

    ```shell
    helm install poolparty \
      --set license.existingSecret=poolparty-license \
      --set configuration.properties.POOLPARTY_GRAPHDB_URL=http://graphdb.default.svc.cluster.local:7200 \
      --set configuration.properties.POOLPARTY_KEYCLOAK_AUTHURL=http://$KEYCLOAK_FQDN/auth \
      --set configuration.properties.POOLPARTY_INDEX_URL=http://elasticsearch.default.svc.cluster.local:9200 \
      poolparty-semantic-suite/poolparty
    ```

See [Configuration](#configuration) and [values.yaml](values.yaml) on how to customize your PoolParty deployment.

### Uninstall

To remove the deployed PoolParty, use:

```shell
helm uninstall poolparty
```

> [!NOTE]
> It is important to note that this will not remove any data, so the next time it is installed, the data will be
> loaded by its components.

## Configuration

Most configuration properties have default values, but as shown in the example above, the URLs to the PoolParty
dependencies must be provided, along with the name of the secret containing the PoolParty license.
If you don't want to specify these on the command line, you can create a file name `values_overrides.yaml` with the
following content:

```yaml
configuration:
  properties:
    POOLPARTY_KEYCLOAK_AUTHURL: http://keycloak.example.com/auth
    POOLPARTY_GRAPHDB_URL: http://graphdb.example.com:7200
    POOLPARTY_INDEX_URL: http://elasticsearch.example.com:9200
```

The install with:

```shell
helm install poolparty poolparty-semantic-suite/poolparty -f values_overrides.yaml
```

### Provisioning Additional Properties and Settings

Most of PoolParty's properties can be passed through `configuration.properties` or `configuration.javaArguments`.
The `configuration` section holds subsections for some of the specific and external components, required by PoolParty.

PoolParty uses Logback to configure logging using the `logback.xml` file.
The file can be provisioned before PoolParty's startup with the `configuration.logback.existingConfigmap` configuration.

### Networking

By default, PoolParty's Helm chart comes with a default Ingress.
The Ingress can be disabled by switching `ingress.enabled` to false.

### Deployment

Some important properties to update according to your deployment are:

* `configuration.externalUrl` - Configures the address at which the Ingress controller and PoolParty are accessible.

### Resources

Default resource limits that are sufficient to deploy the chart and use it with small
sets of data. However, for production deployments it is obligatory to revise these resource limits and tune them for
your environment. You should consider common requirements like amount of data, users, expected traffic.

See the Kubernetes documentation
[Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/)
about defining resource limits.

## Examples

Checkout the [examples/](examples) folder in this repository.

## Values

<!--
IMPORTANT: This is generated by helm-docs, do not attempt modifying it by hand as it will be automatically generated.
-->

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| affinity | object | `{}` |  |
| annotations | object | `{}` |  |
| args | list | `[]` |  |
| automountServiceAccountToken | bool | `false` |  |
| command | list | `[]` |  |
| configuration.defaultJavaArguments | string | `"-XX:MaxRAMPercentage=85"` |  |
| configuration.externalUrl | string | `"http://poolparty.127.0.0.1.nip.io"` |  |
| configuration.javaArguments | string | `""` |  |
| configuration.logback.configmapKey | string | `"logback.xml"` |  |
| configuration.logback.existingConfigmap | string | `""` |  |
| configuration.properties.POOLPARTY_GRAPHDB_PASSWORD | string | `"root"` |  |
| configuration.properties.POOLPARTY_GRAPHDB_URL | string | `"http://graphdb:7200"` |  |
| configuration.properties.POOLPARTY_GRAPHDB_USERNAME | string | `"admin"` |  |
| configuration.properties.POOLPARTY_INDEX_TYPE | string | `"elasticsearch"` |  |
| configuration.properties.POOLPARTY_INDEX_URL | string | `"http://elasticsearch:9200"` |  |
| configuration.properties.POOLPARTY_KEYCLOAK_ADMIN_CLIENTID | string | `"admin-cli"` |  |
| configuration.properties.POOLPARTY_KEYCLOAK_ADMIN_PASSWORD | string | `"admin"` |  |
| configuration.properties.POOLPARTY_KEYCLOAK_ADMIN_REALM | string | `"master"` |  |
| configuration.properties.POOLPARTY_KEYCLOAK_ADMIN_USERNAME | string | `"poolparty_auth_admin"` |  |
| configuration.properties.POOLPARTY_KEYCLOAK_AUTHURL | string | `"http://keycloak:8080/auth"` |  |
| configuration.properties.POOLPARTY_KEYCLOAK_LOGIN_CLIENTID | string | `"ppt"` |  |
| configuration.properties.POOLPARTY_KEYCLOAK_LOGIN_CLIENTSECRET | string | `"yaOd67b2HdQ28hmvuWvZMpn3TLrmhZ1u"` |  |
| configuration.properties.POOLPARTY_KEYCLOAK_LOGIN_ENABLEBASICAUTH | bool | `true` |  |
| configuration.properties.POOLPARTY_KEYCLOAK_LOGIN_PRINCIPALATTRIBUTE | string | `"preferred_username"` |  |
| configuration.properties.POOLPARTY_KEYCLOAK_LOGIN_REALM | string | `"poolparty"` |  |
| configuration.properties._POOLPARTY_ENCRYPTION_PASSWORD | string | `"6wFdqOjvxuyeDvh1ENTm"` |  |
| configuration.propertiesOverrides.existingConfigmap | string | `""` |  |
| configuration.propertiesOverrides.existingSecret | string | `""` |  |
| containerPorts.http | int | `8081` |  |
| dnsConfig | object | `{}` |  |
| dnsPolicy | string | `""` |  |
| extraContainerPorts | object | `{}` |  |
| extraContainers | list | `[]` |  |
| extraEnv | list | `[]` |  |
| extraEnvFrom | list | `[]` |  |
| extraInitContainers | list | `[]` |  |
| extraObjects | list | `[]` |  |
| extraVolumeClaimTemplates | list | `[]` |  |
| extraVolumeMounts | list | `[]` |  |
| extraVolumes | list | `[]` |  |
| fullnameOverride | string | `""` |  |
| global.clusterDomain | string | `"cluster.local"` |  |
| global.imagePullSecrets | list | `[]` |  |
| global.imageRegistry | string | `""` |  |
| image.digest | string | `""` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.pullSecrets | list | `[]` |  |
| image.registry | string | `"docker.io"` |  |
| image.repository | string | `"ontotext/poolparty"` |  |
| image.tag | string | `""` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `true` |  |
| ingress.extraHosts | list | `[]` |  |
| ingress.extraTLS | list | `[]` |  |
| ingress.host | string | `""` |  |
| ingress.labels | object | `{}` |  |
| ingress.path | string | `""` |  |
| ingress.pathType | string | `"Prefix"` |  |
| ingress.tls.enabled | bool | `false` |  |
| ingress.tls.secretName | string | `""` |  |
| initContainerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| initContainerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| initContainerSecurityContext.readOnlyRootFilesystem | bool | `true` |  |
| initContainerSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| labels | object | `{}` |  |
| license.existingSecret | string | `""` |  |
| license.licenseFilename | string | `"poolparty.key"` |  |
| license.optional | bool | `false` |  |
| license.readOnly | bool | `true` |  |
| livenessProbe.httpGet.path | string | `"/PoolParty/health/liveness"` |  |
| livenessProbe.httpGet.port | string | `"http"` |  |
| livenessProbe.initialDelaySeconds | int | `60` |  |
| livenessProbe.periodSeconds | int | `10` |  |
| livenessProbe.timeoutSeconds | int | `5` |  |
| nameOverride | string | `""` |  |
| namespaceOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| persistence.emptyDir.sizeLimit | string | `"1Gi"` |  |
| persistence.enabled | bool | `true` |  |
| persistence.volumeClaimRetentionPolicy | object | `{}` |  |
| persistence.volumeClaimTemplate.annotations | object | `{}` |  |
| persistence.volumeClaimTemplate.labels | object | `{}` |  |
| persistence.volumeClaimTemplate.name | string | `"storage"` |  |
| persistence.volumeClaimTemplate.spec.accessModes[0] | string | `"ReadWriteOnce"` |  |
| persistence.volumeClaimTemplate.spec.resources.requests.storage | string | `"5Gi"` |  |
| podAnnotations | object | `{}` |  |
| podAntiAffinity.enabled | bool | `true` |  |
| podAntiAffinity.preset | string | `"soft"` |  |
| podAntiAffinity.topology | string | `"kubernetes.io/hostname"` |  |
| podLabels | object | `{}` |  |
| podManagementPolicy | string | `"Parallel"` |  |
| podSecurityContext.fsGroup | int | `1001` |  |
| podSecurityContext.fsGroupChangePolicy | string | `"OnRootMismatch"` |  |
| podSecurityContext.runAsGroup | int | `1001` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `1001` |  |
| podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| priorityClassName | string | `""` |  |
| readinessProbe.httpGet.path | string | `"/PoolParty/health/readiness"` |  |
| readinessProbe.httpGet.port | string | `"http"` |  |
| readinessProbe.periodSeconds | int | `10` |  |
| readinessProbe.timeoutSeconds | int | `5` |  |
| resources.limits.memory | string | `"8Gi"` |  |
| resources.requests.cpu | string | `"500m"` |  |
| resources.requests.memory | string | `"8Gi"` |  |
| revisionHistoryLimit | int | `10` |  |
| schedulerName | string | `""` |  |
| securityContext.allowPrivilegeEscalation | bool | `false` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `true` |  |
| securityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| service.annotations | object | `{}` |  |
| service.enabled | bool | `true` |  |
| service.externalIPs | list | `[]` |  |
| service.externalTrafficPolicy | string | `""` |  |
| service.extraPorts | list | `[]` |  |
| service.healthCheckNodePort | string | `""` |  |
| service.labels | object | `{}` |  |
| service.loadBalancerClass | string | `""` |  |
| service.loadBalancerSourceRanges | list | `[]` |  |
| service.nodePort | string | `""` |  |
| service.ports.http | int | `8081` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.name | string | `""` |  |
| startupProbe.failureThreshold | int | `300` |  |
| startupProbe.httpGet.path | string | `"/PoolParty/health/startup"` |  |
| startupProbe.httpGet.port | string | `"http"` |  |
| startupProbe.periodSeconds | int | `3` |  |
| startupProbe.timeoutSeconds | int | `1` |  |
| tempVolume.emptyDir.sizeLimit | string | `"512Mi"` |  |
| tempVolume.enabled | bool | `false` |  |
| tempVolume.volumeClaimRetentionPolicy | object | `{}` |  |
| tempVolume.volumeClaimTemplate.annotations | object | `{}` |  |
| tempVolume.volumeClaimTemplate.labels | object | `{}` |  |
| tempVolume.volumeClaimTemplate.name | string | `"temp-storage"` |  |
| tempVolume.volumeClaimTemplate.spec.accessModes[0] | string | `"ReadWriteOnce"` |  |
| tempVolume.volumeClaimTemplate.spec.resources.requests.storage | string | `"5Gi"` |  |
| terminationGracePeriodSeconds | int | `120` |  |
| tolerations | list | `[]` |  |
| topologySpreadConstraints | list | `[]` |  |
| updateStrategy.type | string | `"RollingUpdate"` |  |

## Troubleshooting

**Connection issues**

If connections time out or the pods cannot resolve each other, it is likely that the Kubernetes DNS is broken. This is a
common issue with Minikube between system restarts or when inappropriate Minikube driver is used. Please refer to
[Debugging DNS Resolution](https://kubernetes.io/docs/tasks/administer-cluster/dns-debugging-resolution/).

**Filesystem provisioning errors (in Multi-Node Minikube Cluster)**

When expanding your Minikube cluster from one to two or more nodes to deploy different PoolParty instances across
multiple nodes to ensure high availability, you may encounter errors when setting up persistent storage. These issues
are due to implementation problems with the storage provisioner included with Minikube. To resolve this, you need to
adjust your environment accordingly. Follow the steps outlined in the official Minikube documentation under the
["CSI Driver and Volume Snapshots"](https://minikube.sigs.k8s.io/docs/tutorials/volume_snapshots_and_csi/) section,
specifically in the "Multi-Node Clusters" chapter.

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Graphwise | <dnd@graphwise.ai> |  |

## Contributing

If you have any suggestions, bug reports, or feature requests, please open an issue or submit a pull request.

## License

This code is released under the Apache 2.0 License. See [LICENSE](LICENSE) for more details.
