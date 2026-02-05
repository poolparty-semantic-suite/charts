# Provisioning External Server Map Configuration

When deploying the Mirror App, it needs an additional JSON file, which holds the configurations for the source and
target (destination) of the mirrored projects data.

The current directory contains simple example on how to provision such configuration to the application.

## Details

As you can see in the [values.yaml](./values.yaml) there is a specific configuration that allows you to provide
[ConfigMap Object](https://kubernetes.io/docs/concepts/configuration/configmap/), which will be used to create the JSON
file on the running container.

```yaml
configuration:
  existingServerMap:
    # The name of the ConfigMap object.
    configmap: mirror-app-server-config   <----
```

To provide the file, you just need to create ConfigMap holding the content of the JSON file and provide its name to the
`existingServerMap.configmap` configuration as shown above.
