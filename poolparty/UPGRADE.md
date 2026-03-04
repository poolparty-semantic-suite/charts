# Migration Guide

## Configuring Unique Elasticsearch Index Names for Multi-Instance Deployments

Starting with PoolParty 10.2.0 (Helm chart 0.2.x), each PoolParty instance can be configured with its own
Elasticsearch index prefix and/or suffix. This is required when multiple PoolParty instances share a single
Elasticsearch cluster. Without unique names, all instances would read and write the same indices.

### New Deployments

For a brand-new deployment that will share an Elasticsearch cluster with other PoolParty instances, set a prefix
and/or suffix before the first startup:

```yaml
configuration:
  properties:
    POOLPARTY_ELASTICSEARCH_INDEX_PREFIX: "instance1-"
    # POOLPARTY_ELASTICSEARCH_INDEX_SUFFIX: ""  # optional
```

On first startup PoolParty will create its indices using the configured names (e.g. `instance1-conceptdata`,
`instance1-searchdata`, etc.).

### Existing Deployments — Enabling a Prefix or Suffix

If you have an existing single-instance deployment with data already indexed in Elasticsearch (indices named
`conceptdata`, `searchdata`, etc.) and you now want to enable a prefix or suffix:

1. **Stop the running PoolParty instance.**

2. **Add the prefix/suffix to your Helm values:**

   ```yaml
   configuration:
     properties:
       POOLPARTY_ELASTICSEARCH_INDEX_PREFIX: "instance1-"
   ```

3. **Upgrade the Helm release:**

   ```shell
   helm upgrade poolparty poolparty-semantic-suite/poolparty -f your-values.yaml
   ```

4. **Start PoolParty.** On the first startup with the new configuration, PoolParty automatically creates
   Elasticsearch **aliases** that map the new prefixed index names to the existing underlying indices. For example:
   - Alias `instance1-conceptdata` → index `conceptdata`
   - Alias `instance1-searchdata` → index `searchdata`
   - … (one alias per managed index)

   All reads and writes go through the alias, so the application behaves identically to before.
   **No data is moved or copied.**

> [!NOTE]
> The alias is only created automatically if the original index has no existing aliases. If another PoolParty
> instance already holds an alias on a given index, this instance will create a fresh, empty index under the
> prefixed name instead.

> [!CAUTION]
> Do **not** run the old (unprefixed) instance and the new (prefixed) instance simultaneously against the same
> Elasticsearch cluster. Both would write to the same underlying indices via different names, corrupting data.
> Perform the migration during a maintenance window.

### Verifying the Migration

After startup, use the Elasticsearch Aliases API to confirm the aliases were created:

```shell
curl http://<elasticsearch-host>:9200/_aliases?pretty
```

You should see entries like:

```json
{
  "conceptdata": {
    "aliases": {
      "instance1-conceptdata": {}
    }
  },
  "searchdata": {
    "aliases": {
      "instance1-searchdata": {}
    }
  }
}
```

If you need to add a second instance to the same cluster later, assign it a different prefix (e.g. `instance2-`).
PoolParty will create fresh indices for it because the legacy index already has aliases from the first instance.
