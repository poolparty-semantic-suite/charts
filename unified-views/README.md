# Helm Chart for UnifiedViews

[![CI - Pull Request](https://github.com/poolparty-semantic-suite/charts/actions/workflows/pull-request.yml/badge.svg)](https://github.com/poolparty-semantic-suite/charts/actions/workflows/pull-request.yml)
![Version: 0.1.1](https://img.shields.io/badge/Version-0.1.1-informational?style=flat-square)
![AppVersion: 10.2.0](https://img.shields.io/badge/AppVersion-10.2.0-informational?style=flat-square)

Welcome to the official [Helm](https://helm.sh/) chart repository for
[PoolParty's UnifiedViews](https://www.poolparty.biz/poolparty-unifiedviews)!
This Helm chart makes it easy to deploy and manage UnifiedViews on your [Kubernetes](https://kubernetes.io/) cluster.

# About UnifiedViews

PoolParty's UnifiedViews is an Extract-Transform-Load (ETL) framework that natively supports RDF data and ontologies.
It helps organizations to integrate different data types and connect them in a knowledge graph so that enterprise data
and content can be searched for and used effectively.

# Versioning

The Helm chart follows [Semantic Versioning v2](https://semver.org/) so any breaking changes will be rolled out only in
MAJOR versions of the chart.

Please, always check out the migration guides in [UPGRADE.md](UPGRADE.md), before switching to another major version of
the Helm chart.

The chart has it's own version and it's not the same as the version of UnifiedViews.
The table bellow highlights the version mapping between the Helm chart and UnfieldViews.

| Helm chart version | UnfieldViews version |
|--------------------|----------------------|
| 0.1.x              | 10.2.x               |

# Prerequisites

* Kubernetes v1.32+
* Helm v3.18+
* kubectl

# Installation

## Dependencies

UnifiedViews depends on [RDF4J Workbench](https://rdf4j.org/documentation/tools/server-workbench/) to store information
about the running pipelines.

To make the deployment more convenient and easy to use, we've included the `RDF4J Workbench` as additional application
container (Pod) that is started alongside the UnifiedViews.

It is possible to use different remote instance. In that case just disable the RDF4J in the current chart and provide
RDF4J connection configurations to the UnifiedViews.

An example of using different remote RDF4J instance:

```yaml
configuration:
  rdf4j:
    url: https://my-remote-rdf4j-workbench.com/rdf4j-workbench
    repositoryName: my-custom-uv-repo

rdf4j:
  enabled: false
```

## UnifiedViews

> [!NOTE]
> UnifiedViews requires a license. You need to obtain a license file before installing.

1. Create a secret for the UnifiedViews license

    ```shell
    kubectl create secret generic uv-license --from-file uv-license.key=/path/to/uv-license.key
    ```

2. Add the UnfieldViews Helm repository

    ```shell
    helm repo add poolparty-semantic-suite https://poolparty-semantic-suite.github.io/charts
    helm repo update
    ```

3. Install UnfieldViews

    ```shell
    helm install unified-views poolparty-semantic-suite/unified-views
    ```

See [Configuration](#configuration) and [values.yaml](values.yaml) on how to customize your UnifiedViews deployment.

### Uninstall

To remove the deployed UnifiedViews, use:

```shell
helm uninstall unified-views
```

> [!NOTE]
> It is important to note that this will not remove any data, so the next time it is installed, the data will be
> loaded by its components.

## Configuration

Most configuration properties have default values. If you don't want to specify these on the command line, you can
create a file name `values_overrides.yaml` with the following content:

```yaml
configuration:
  properties:
    database.rdf.conf.url: http://rdf4j:8080/rdf4j-server
```

Install with:

```shell
helm install unified-views poolparty-semantic-suite/unified-views -f values_overrides.yaml
```

### Provisioning Additional Properties and Settings

Most of UnfieldViews properties can be passed through `configuration.properties` or `configuration.javaArguments`.
The `configuration` section holds subsections for some of the specific and external components, required by UnfieldViews.

TODO: check if that is the case
UnfieldViews uses Logback to configure logging using the `logback.xml` file.
The file can be provisioned before UnfieldViews startup with the `configuration.logback.existingConfigmap` configuration.

### Networking

By default, UnfieldViews Helm chart comes with a default Ingress.
The Ingress can be disabled by switching `ingress.enabled` to false.

### Deployment

Some important properties to update according to your deployment are:

* `configuration.externalUrl` - Configures the address at which the Ingress controller and UnfieldViews are accessible.

### Resources

Default resource limits that are sufficient to deploy the chart and use it with small sets of data. However, for
production deployments it is obligatory to revise these resource limits and tune them for your environment. You should
consider common requirements like amount of data, users, expected traffic.

See the Kubernetes documentation
[Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/)
about defining resource limits.

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
| configuration.defaultJavaArguments | string | `"-XX:MaxRAMPercentage=85 -Dcatalina.log.path=/tmp/tomcat"` |  |
| configuration.externalUrl | string | `"http://unified-views.127.0.0.1.nip.io"` |  |
| configuration.javaArguments | string | `""` |  |
| configuration.logback.configmapKey | string | `"logback.xml"` |  |
| configuration.logback.existingConfigmap | string | `""` |  |
| configuration.properties | object | `{}` |  |
| configuration.rdf4j.passwordSecret.key | string | `""` |  |
| configuration.rdf4j.passwordSecret.name | string | `"password"` |  |
| configuration.rdf4j.platform | string | `"remoteRDF"` |  |
| configuration.rdf4j.repositoryName | string | `"uv"` |  |
| configuration.rdf4j.url | string | `""` |  |
| configuration.rdf4j.user | string | `""` |  |
| configuration.sso.keycloak.enabled | bool | `false` |  |
| configuration.sso.keycloak.oidcClientId | string | `""` |  |
| configuration.sso.keycloak.oidcClientName | string | `""` |  |
| configuration.sso.keycloak.oidcClientSecret.key | string | `""` |  |
| configuration.sso.keycloak.oidcClientSecret.name | string | `"secret"` |  |
| containerPorts.http | int | `8080` |  |
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
| image.repository | string | `"ontotext/unifiedviews"` |  |
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
| initContainerDataPermissions.enabled | bool | `true` |  |
| initContainerDataPermissions.securityContext.runAsNonRoot | bool | `false` |  |
| initContainerDataPermissions.securityContext.runAsUser | int | `0` |  |
| initContainerResources.limits.cpu | string | `"500m"` |  |
| initContainerResources.limits.memory | string | `"1Gi"` |  |
| initContainerResources.requests.cpu | string | `"500m"` |  |
| initContainerResources.requests.memory | string | `"1Gi"` |  |
| initContainerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| initContainerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| initContainerSecurityContext.readOnlyRootFilesystem | bool | `false` |  |
| initContainerSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| labels | object | `{}` |  |
| license.existingSecret | string | `"uv-license"` |  |
| license.licenseFilename | string | `"uv-license.key"` |  |
| license.optional | bool | `false` |  |
| license.readOnly | bool | `true` |  |
| livenessProbe.httpGet.path | string | `"/master/api/1/health/liveness"` |  |
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
| podSecurityContext.fsGroup | int | `10001` |  |
| podSecurityContext.fsGroupChangePolicy | string | `"OnRootMismatch"` |  |
| podSecurityContext.runAsGroup | int | `10001` |  |
| podSecurityContext.runAsNonRoot | bool | `true` |  |
| podSecurityContext.runAsUser | int | `10001` |  |
| podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| priorityClassName | string | `""` |  |
| rdf4j.affinity | object | `{}` |  |
| rdf4j.args | list | `[]` |  |
| rdf4j.automountServiceAccountToken | bool | `false` |  |
| rdf4j.command | list | `[]` |  |
| rdf4j.configuration.defaultJavaArguments | string | `"-XX:+UseContainerSupport -XX:MaxRAMPercentage=85"` |  |
| rdf4j.configuration.javaArguments | string | `""` |  |
| rdf4j.configuration.logback.configmapKey | string | `"logback.xml"` |  |
| rdf4j.configuration.logback.existingConfigmap | string | `""` |  |
| rdf4j.containerPorts.http | int | `8080` |  |
| rdf4j.dnsConfig | object | `{}` |  |
| rdf4j.dnsPolicy | string | `""` |  |
| rdf4j.enabled | bool | `true` |  |
| rdf4j.extraContainerPorts | object | `{}` |  |
| rdf4j.extraContainers | list | `[]` |  |
| rdf4j.extraEnv | list | `[]` |  |
| rdf4j.extraEnvFrom | list | `[]` |  |
| rdf4j.extraInitContainers | list | `[]` |  |
| rdf4j.extraVolumeClaimTemplates | list | `[]` |  |
| rdf4j.extraVolumeMounts | list | `[]` |  |
| rdf4j.extraVolumes | list | `[]` |  |
| rdf4j.fullnameOverride | string | `""` |  |
| rdf4j.image.digest | string | `""` |  |
| rdf4j.image.pullPolicy | string | `"IfNotPresent"` |  |
| rdf4j.image.pullSecrets | list | `[]` |  |
| rdf4j.image.registry | string | `"docker.io"` |  |
| rdf4j.image.repository | string | `"eclipse/rdf4j-workbench"` |  |
| rdf4j.image.tag | string | `"4.3.15"` |  |
| rdf4j.initContainerDataPermissions.enabled | bool | `true` |  |
| rdf4j.initContainerDataPermissions.securityContext.runAsNonRoot | bool | `false` |  |
| rdf4j.initContainerDataPermissions.securityContext.runAsUser | int | `0` |  |
| rdf4j.initContainerResources.limits.cpu | string | `"100m"` |  |
| rdf4j.initContainerResources.limits.memory | string | `"256Mi"` |  |
| rdf4j.initContainerResources.requests.cpu | string | `"100m"` |  |
| rdf4j.initContainerResources.requests.memory | string | `"256Mi"` |  |
| rdf4j.initContainerSecurityContext.allowPrivilegeEscalation | bool | `false` |  |
| rdf4j.initContainerSecurityContext.capabilities.drop[0] | string | `"ALL"` |  |
| rdf4j.initContainerSecurityContext.readOnlyRootFilesystem | bool | `false` |  |
| rdf4j.initContainerSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| rdf4j.livenessProbe.httpGet.path | string | `"/rdf4j-server"` |  |
| rdf4j.livenessProbe.httpGet.port | string | `"http"` |  |
| rdf4j.livenessProbe.initialDelaySeconds | int | `60` |  |
| rdf4j.livenessProbe.periodSeconds | int | `10` |  |
| rdf4j.livenessProbe.timeoutSeconds | int | `5` |  |
| rdf4j.nameOverride | string | `""` |  |
| rdf4j.nodeSelector | object | `{}` |  |
| rdf4j.persistence.emptyDir.sizeLimit | string | `"500Mi"` |  |
| rdf4j.persistence.enabled | bool | `true` |  |
| rdf4j.persistence.volumeClaimRetentionPolicy | object | `{}` |  |
| rdf4j.persistence.volumeClaimTemplate.annotations | object | `{}` |  |
| rdf4j.persistence.volumeClaimTemplate.labels | object | `{}` |  |
| rdf4j.persistence.volumeClaimTemplate.name | string | `"storage"` |  |
| rdf4j.persistence.volumeClaimTemplate.spec.accessModes[0] | string | `"ReadWriteOnce"` |  |
| rdf4j.persistence.volumeClaimTemplate.spec.resources.requests.storage | string | `"500Mi"` |  |
| rdf4j.podAnnotations | object | `{}` |  |
| rdf4j.podAntiAffinity.enabled | bool | `true` |  |
| rdf4j.podAntiAffinity.preset | string | `"soft"` |  |
| rdf4j.podAntiAffinity.topology | string | `"kubernetes.io/hostname"` |  |
| rdf4j.podDisruptionBudget.enabled | bool | `true` |  |
| rdf4j.podDisruptionBudget.maxUnavailable | string | `""` |  |
| rdf4j.podDisruptionBudget.minAvailable | string | `"51%"` |  |
| rdf4j.podLabels | object | `{}` |  |
| rdf4j.podManagementPolicy | string | `"Parallel"` |  |
| rdf4j.podSecurityContext.fsGroup | int | `10001` |  |
| rdf4j.podSecurityContext.fsGroupChangePolicy | string | `"OnRootMismatch"` |  |
| rdf4j.podSecurityContext.runAsGroup | int | `10001` |  |
| rdf4j.podSecurityContext.runAsNonRoot | bool | `true` |  |
| rdf4j.podSecurityContext.runAsUser | int | `10001` |  |
| rdf4j.podSecurityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| rdf4j.priorityClassName | string | `""` |  |
| rdf4j.readinessProbe.httpGet.path | string | `"/rdf4j-server"` |  |
| rdf4j.readinessProbe.httpGet.port | string | `"http"` |  |
| rdf4j.readinessProbe.periodSeconds | int | `10` |  |
| rdf4j.readinessProbe.timeoutSeconds | int | `50` |  |
| rdf4j.resources.limits.memory | string | `"1500Mi"` |  |
| rdf4j.resources.requests.cpu | string | `"100m"` |  |
| rdf4j.resources.requests.memory | string | `"1500Mi"` |  |
| rdf4j.revisionHistoryLimit | int | `10` |  |
| rdf4j.schedulerName | string | `""` |  |
| rdf4j.securityContext.allowPrivilegeEscalation | bool | `false` |  |
| rdf4j.securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| rdf4j.securityContext.readOnlyRootFilesystem | bool | `true` |  |
| rdf4j.securityContext.seccompProfile.type | string | `"RuntimeDefault"` |  |
| rdf4j.service.annotations | object | `{}` |  |
| rdf4j.service.enabled | bool | `true` |  |
| rdf4j.service.externalIPs | list | `[]` |  |
| rdf4j.service.externalTrafficPolicy | string | `""` |  |
| rdf4j.service.extraPorts | list | `[]` |  |
| rdf4j.service.healthCheckNodePort | string | `""` |  |
| rdf4j.service.labels | object | `{}` |  |
| rdf4j.service.loadBalancerClass | string | `""` |  |
| rdf4j.service.loadBalancerSourceRanges | list | `[]` |  |
| rdf4j.service.nodePort | string | `""` |  |
| rdf4j.service.ports.http | int | `8080` |  |
| rdf4j.service.type | string | `"ClusterIP"` |  |
| rdf4j.startupProbe.failureThreshold | int | `120` |  |
| rdf4j.startupProbe.httpGet.path | string | `"/rdf4j-server"` |  |
| rdf4j.startupProbe.httpGet.port | string | `"http"` |  |
| rdf4j.startupProbe.periodSeconds | int | `3` |  |
| rdf4j.startupProbe.timeoutSeconds | int | `1` |  |
| rdf4j.terminationGracePeriodSeconds | int | `30` |  |
| rdf4j.tolerations | list | `[]` |  |
| rdf4j.topologySpreadConstraints | list | `[]` |  |
| rdf4j.updateStrategy.type | string | `"RollingUpdate"` |  |
| readinessProbe.httpGet.path | string | `"/master/api/1/health/readiness"` |  |
| readinessProbe.httpGet.port | string | `"http"` |  |
| readinessProbe.periodSeconds | int | `10` |  |
| readinessProbe.timeoutSeconds | int | `5` |  |
| resources.limits.memory | string | `"5Gi"` |  |
| resources.requests.cpu | string | `"500m"` |  |
| resources.requests.memory | string | `"2Gi"` |  |
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
| service.ports.http | int | `8080` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `false` |  |
| serviceAccount.name | string | `""` |  |
| startupProbe.failureThreshold | int | `300` |  |
| startupProbe.httpGet.path | string | `"/master/api/1/health/startup"` |  |
| startupProbe.httpGet.port | string | `"http"` |  |
| startupProbe.periodSeconds | int | `3` |  |
| startupProbe.timeoutSeconds | int | `1` |  |
| tempVolume.emptyDir.sizeLimit | string | `"2Gi"` |  |
| tempVolume.enabled | bool | `true` |  |
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
