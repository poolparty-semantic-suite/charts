# Configuring PoolParty

This document provides detailed instructions on how to configure PoolParty, including setting properties, secret
properties and additional configurations.

It covers various methods to manage configuration options, such as using ConfigMaps and Secrets, and highlights some
good practices to ensure secure and efficient setup. Additionally, it explains how to set Java arguments and environment
variables for PoolParty.

All PoolParty configuration options can be found TODO docs reference.

## Properties

This section is used to set PoolParty properties in the default ConfigMap directly from the `values.yaml` file.
The configurations, typically including non-sensitive information such as product settings, external components
addresses and so on.
The default ConfigMap is used as source for environment variables, if it isn't overridden.

```yaml
configuration:
  properties:
    POOLPARTY_GRAPHDB_URL: "https://graphdb.custom-domain.com/"
    POOLPARTY_KEYCLOAK_AUTHURL: "https://keycloak.custom-domain.com/auth"
    POOLPARTY_INDEX_URL: "https://elastic.custom-domain.com/"
```

## Properties Overrides

This section explains how to configure properties for PoolParty using an existing Kubernetes ConfigMap or an existing
Secret. The resources mentioned in this section can be found in the [resources.yaml](./resources.yaml) file.

The appropriate resources are used for each specific case.

### Using Existing ConfigMap

```yaml
configuration:
  propertiesOverrides:
    existingConfigmap: custom-poolparty-properties
```

### Using Existing Secret

```yaml
configuration:
  propertiesOverrides:
    existingSecret: custom-poolparty-secret-properties
```

## Java Arguments

This section explains how to set Java arguments for PoolParty using the `values.yaml` file. The
`configuration.javaArguments` field allows you to specify Java Virtual Machine (JVM) options, such as memory settings,
to optimize the performance and resource usage of the PoolParty instance.

It also supports PoolParty properties in the form of `-Dproperty=value`.

```yaml
configuration:
  javaArguments: "-Xms4G -Xmx4G -Dpoolparty.server.port=8081"
```

## Extra Environment Variables from a Source

This section explains how to configure PoolParty with environment variables using an existing Kubernetes ConfigMap or an
existing Secrets. This approach ensures that additional configurations are injected alongside existing or default ones
without mixing different contexts.

The resources referenced in this section can be found in the [resources.yaml](./resources.yaml) file.

```yaml
configuration:
  properties:
    ENCRYPTION_KEYSTRENGTH: 512
    POOLPARTY_APPS: "thesaurus, graphsearch, extractor"

extraEnvFrom:
  - configMapRef:
      name: custom-poolparty-properties
  - secretRef:
      name: custom-poolparty-secret-properties
```

## Extra Environment Variables

This section demonstrates how environment variables can be directly set up in the Helm chart's `values.yaml` file,
eliminating the need to configure them separately in a ConfigMap or Secret.

```yaml
extraEnv:
  - name: "POOLPARTY_GRAPHDB_URL"
    value: "https://graphdb.custom-domain.com"
```

## Final words

The most recommended way of configuration PoolParty is by using existing resources, especially for the sensitive
information. In this cases `configuration.propertiesOverrides` and `extraEnvFrom` are most suitable for this.

For non-sensitive information any method of configuring PoolParty is viable.
