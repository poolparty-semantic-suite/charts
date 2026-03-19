### Elasticsearch Index Naming for Multi-Instance Deployments

By default, PoolParty uses fixed Elasticsearch index names (e.g. `conceptdata`, `searchdata`). This means a single
Elasticsearch cluster **cannot be safely shared** between multiple PoolParty instances — they would read and write the
same indices.

To run multiple PoolParty instances against one Elasticsearch cluster, each instance must be assigned unique index names
using a prefix, a suffix, or both.

#### Configuration

Set one or both of the following properties under `configuration.properties`:

| Property | Description |
|----------|-------------|
| `POOLPARTY_ELASTICSEARCH_INDEX_PREFIX` | String prepended to every Elasticsearch index name. |
| `POOLPARTY_ELASTICSEARCH_INDEX_SUFFIX` | String appended to every Elasticsearch index name. |

With `POOLPARTY_ELASTICSEARCH_INDEX_PREFIX: "instance1-"`, the index `conceptdata` becomes `instance1-conceptdata`,
`searchdata` becomes `instance1-searchdata`, and so on for all indices managed by that instance.

> [!IMPORTANT]
> Every instance that shares the same Elasticsearch cluster must use a distinct combination of prefix and suffix.
> Two instances with the same prefix and suffix will conflict over the same indices.

> [!NOTE]
> A single, isolated PoolParty deployment does not require these properties. They are only necessary when multiple
> instances share one Elasticsearch cluster.

#### Example: Two Instances Sharing One Elasticsearch Cluster

Create one `values` override file per instance:

```yaml
# values-instance1.yaml
configuration:
  properties:
    POOLPARTY_INDEX_URL: http://elasticsearch.default.svc.cluster.local:9200
    POOLPARTY_ELASTICSEARCH_INDEX_PREFIX: "instance1-"
```

```yaml
# values-instance2.yaml
configuration:
  properties:
    POOLPARTY_INDEX_URL: http://elasticsearch.default.svc.cluster.local:9200
    POOLPARTY_ELASTICSEARCH_INDEX_PREFIX: "instance2-"
```

Then install each instance as a separate Helm release:

```shell
helm install poolparty-instance1 poolparty-semantic-suite/poolparty \
  --set license.existingSecret=poolparty-license-instance1 \
  -f values-instance1.yaml

helm install poolparty-instance2 poolparty-semantic-suite/poolparty \
  --set license.existingSecret=poolparty-license-instance2 \
  -f values-instance2.yaml
```

On first startup each instance will create its own set of prefixed indices
(`instance1-conceptdata`, `instance1-searchdata`, … and `instance2-conceptdata`, `instance2-searchdata`, …), fully
isolated from one another within the shared cluster.

#### Migrating an Existing Single-Instance Deployment to Use a Prefix or Suffix

If you already have a running PoolParty instance with data in Elasticsearch and you want to add a prefix or suffix,
PoolParty handles the transition automatically on the next startup:

1. For each index that exists under its original name (e.g. `conceptdata`) and has **no existing aliases**, PoolParty
   creates an Elasticsearch alias `<prefix>conceptdata<suffix>` → `conceptdata`. The application immediately starts
   using the alias, so all reads and writes continue to hit the same underlying index. **No data is moved or copied.**
2. If the original index already has an alias pointing to it (because another instance already claimed it), PoolParty
   creates a brand-new index under the prefixed/suffixed name instead and leaves the original index untouched.

The net result is that adding a prefix or suffix to an existing deployment is safe and requires no manual data
migration.

> [!CAUTION]
> Before enabling a prefix or suffix on a running instance, ensure no other PoolParty instance is currently writing to
> the same Elasticsearch cluster without its own prefix or suffix configured. Running two instances concurrently against
> the same unprefixed index would corrupt data.
