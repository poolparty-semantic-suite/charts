# Elasticsearch Example

**Do not use this example in production setup!**

The current directory contains an example, showcasing how to set up a simple Elasticsearch instance and configure
PoolParty to work with it.

As already mentioned, PoolParty requires Elasticsearch for data indexing and for now, it is considered required external
component for the Graphwise Platform.

## Quickstart

The [elasticsearch.yaml](elasticsearch.yaml) file contains few Kubernetes objects that will install single instance of
Elasticsearch, when applied.

To apply them just execute the following command:

```shell
kubectl apply -f elasticsearch.yaml
```

**Note**: if you are using different *namespace* make sure to update the objects in the file accordingly and when
          executing the `kubectl apply` pass on the `-n <namespace>` argument.

## Configurations

You can customize additionally the example, if you plan to experiment or test specific use cases. You can do that by
providing additional environment variables in the `StatefulSet` object.

See `spec.template.spec.containers.[0].env` section.

**SSL**

As you can see, the Elasticsearch instance is configured without `ssl`:

```yaml
- name: "xpack.security.transport.ssl.enabled"
  value: "false"
```

If you want to enable it, you need to provide certificates and mount them as files or secrets.

**Default Password**

To change the default password in the example, update the `elasticsearch-secret-properties` Secret Object. If you do
that, make sure to pass the value to the PoolParty as well.

**Additional Notes**

- The image for the Elasticsearch is provided by us as it contains some extensions needed by PoolParty
- The readiness, liveness and startup probes are very naive and simplified just for the sake of the example. They should
  not be used in production setup.

### PoolParty

The [values.override.yaml](values.override.yaml) shows which configuration properties should be added to to PoolParty in
order to use the Elasticsearch instance that will be installed.
