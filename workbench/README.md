# Helm Chart for PoolParty Workbench

[![CI - Pull Request](https://github.com/poolparty-semantic-suite/charts/actions/workflows/pull-request.yml/badge.svg)](https://github.com/poolparty-semantic-suite/charts/actions/workflows/pull-request.yml)
![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square)
![AppVersion: 10.0.1](https://img.shields.io/badge/AppVersion-10.0.1-informational?style=flat-square)

TODO: we need info here
Welcome to the official [Helm](https://helm.sh/) chart repository for [PoolParty Workbench](https://www.poolparty.biz/)!
This Helm chart makes it easy to deploy and manage PoolParty on your [Kubernetes](https://kubernetes.io/) cluster.

# About PoolParty Workbench

TODO: ?????

# Versioning

The Helm chart follows [Semantic Versioning v2](https://semver.org/) so any breaking changes will be rolled out only in
MAJOR versions of the chart.

Please, always check out the migration guides in [UPGRADE.md](UPGRADE.md), before switching to another major version of
the Helm chart.

The chart has it's own version and it's not the same as the version of PoolParty Workbench application.
The table bellow highlights the version mapping between the Helm chart and PoolParty Workbench.

| Helm chart version | PoolParty Workbench version |
|--------------------|-----------------------------|
| 0.1.x              | 2.3.x                       |

# Prerequisites

* Kubernetes v1.30+
* Helm v3.18+
* kubectl

# Installation

## Dependencies

PoolParty Workbench requires running PoolParty, to which it will connect and basically extend. For more details about
PoolParty installation, please check the `/poolparty` directory and the [README.md](../poolparty/README.md) file there.

## PoolParty Workbench

With all dependencies in place, the Workbench can be installed.

TODO: to be seen...
> [!NOTE]
> PoolParty Workbench requires a license. You need to obtain a license file before installing.

1. Create a secret for the PoolParty license

    ```shell
    kubectl create secret generic poolparty-license --from-file poolparty.key=/path/to/poolparty.key
    ```

2. Add the PoolParty Workbench Helm repository

    ```shell
    helm repo add poolparty-semantic-suite https://poolparty-semantic-suite.github.io/charts
    helm repo update
    ```

3. Install PoolParty Workbench

    ```shell
    helm install poolparty-workbench \
      --set license.existingSecret=poolparty-license \
      poolparty-semantic-suite/poolparty-workbench
    ```

See [Configuration](#configuration) and [values.yaml](values.yaml) on how to customize your PoolParty Workbench
deployment.

### Uninstall

To remove the deployed PoolParty Workbench, use:

```shell
helm uninstall poolparty-workbench
```

> [!NOTE]
> It is important to note that this will not remove any data, so the next time it is installed, the data will be
> loaded by its components.

TODO: Revision once we have Docker image
## Configuration

Most configuration properties have default values, but as shown in the example above, the URLs to the PoolParty
dependencies must be provided, along with the name of the secret containing the PoolParty license.
If you don't want to specify these on the command line, you can create a file name `values_overrides.yaml` with the
following content:

```yaml
configuration:
  properties:
    .....
```

The install with:
```shell
helm install poolparty-workbench poolparty-semantic-suite/poolparty-workbench -f values_overrides.yaml
```

### Provisioning Additional Properties and Settings

Most of PoolParty Workbench's properties can be passed through `configuration.properties` or
`configuration.javaArguments`. 
The `configuration` section holds subsections for some of the specific and external components, required by the
application.

TODO: most likely no
PoolParty Workbench uses Logback to configure logging using the `logback.xml` file.
The file can be provisioned before PoolParty's startup with the `configuration.logback.existingConfigmap` configuration.

### Networking

By default, PoolParty Workbench's Helm chart comes with a default Ingress.
The Ingress can be disabled by switching `ingress.enabled` to false.

### Deployment

Some important properties to update according to your deployment are:

* `configuration.externalUrl` - Configures the address at which the Ingress controller and PoolParty Workbench are
  accessible.

### Resources

Default resource limits that are sufficient to deploy the chart and use it with small sets of data. However, for
production deployments it is obligatory to revise these resource limits and tune them for your environment. You should
consider common requirements like amount of data, users, expected traffic.

See the Kubernetes documentation
[Resource Management for Pods and Containers](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/)
about defining resource limits.

## Examples

TODO
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
| configuration.externalUrl | string | `"http://poolparty-workbench.127.0.0.1.nip.io"` |  |
| configuration.javaArguments | string | `""` |  |
| configuration.logback.configmapKey | string | `"logback.xml"` |  |
| configuration.logback.existingConfigmap | string | `""` |  |
| configuration.properties.TODO | string | `"examples and defaults"` |  |
| configuration.propertiesOverrides.existingConfigmap | string | `""` |  |
| configuration.propertiesOverrides.existingSecret | string | `""` |  |
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
| image.repository | string | `"ontotext/poolparty-workbench"` |  |
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
| livenessProbe.httpGet.path | string | `"/"` |  |
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
| readinessProbe.httpGet.path | string | `"/"` |  |
| readinessProbe.httpGet.port | string | `"http"` |  |
| readinessProbe.periodSeconds | int | `10` |  |
| readinessProbe.timeoutSeconds | int | `5` |  |
| resources.limits.memory | string | `"512Mi"` |  |
| resources.requests.cpu | string | `"500m"` |  |
| resources.requests.memory | string | `"1Gi"` |  |
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
| startupProbe.httpGet.path | string | `"/"` |  |
| startupProbe.httpGet.port | string | `"http"` |  |
| startupProbe.periodSeconds | int | `3` |  |
| startupProbe.timeoutSeconds | int | `1` |  |
| tempVolume.emptyDir.sizeLimit | string | `"128Mi"` |  |
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

When expanding your Minikube cluster from one to two or more nodes to deploy different PoolParty Workbench instances
across multiple nodes to ensure high availability, you may encounter errors when setting up persistent storage. These
issues are due to implementation problems with the storage provisioner included with Minikube. To resolve this, you need
to adjust your environment accordingly. Follow the steps outlined in the official Minikube documentation under the
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
