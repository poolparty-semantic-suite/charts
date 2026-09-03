# Migration and Upgrade Guide

> [!CAUTION]
> If you are migrating from old version of the chart, please read through the document. You need to run the migrations
> for the Elasticsearch and Keycloak, depending on the versions you are using.  
> See sections `Helm Chart 0.3.0 (App 10.2)` and `Helm Chart 1.0.0 (App 10.3)`.

## Helm Chart 1.0.0 (App 10.3)

Updating to version **1.0.0** of the Graph Modeling (ex. PoolParty) chart requires several modifications of the
configurations and couple of manual steps while deploying the components.

Version **1.0.0** of the chart, updates the application version to **10.3**, which requires update of the custom
**Keycloak image** to **2.6.0**. The new Keycloak image contains automatic migration of the realm configurations in
order to tighten up the security policies and communication aspects for all components of the Graphwise Platform.

### Preparation and Configuration Changes

To prepare for the update, first you need to modify the configuration properties of both Graph Modeling and Keycloak.

#### Keycloak Configuration Changes

The update of Keycloak consists of bumping the version of the image to **2.6.0** and modifying or overriding the values
of the following lists of properties:

**New**

- `KC_HOSTNAME_BACKCHANNEL_DYNAMIC` - toggles the dynamic resolving of backchannel URLs, including hostname, scheme,
  port and context path.
  
  Set to `true` if your application(s) access Keycloak via a private network. When set to `true`, hostname option needs
  to be specified as a full URL.

- `GRAPHDB_PUBLIC_URL` - sets to the public URL of the GraphDB instance, used for the Graph Modeling. The configuration
  is used to prepare specific client and whitelist the primary GraphDB address. The change is part of the initiative for
  the unified security model for the Graphwise Platform.

- `PPT_KEYCLOAK_LOGIN_CLIENTSECRET` - a secret to set for the `ppt` client. Used when creating the clients for the
  separate Graph Modeling services. Part of the `2.6.0` migration. Recommended, alphanumeric value, 32 characters.

- `EXTRACTOR_KEYCLOAK_LOGIN_CLIENTSECRET` - a secret to set for the `extractor` client. Used when creating the clients
  for the separate Graph Modeling services. Part of the `2.6.0` migration. Recommended, alphanumeric value, 32
  characters.

- `PPGS_KEYCLOAK_LOGIN_CLIENTSECRET` - a secret to set for the `ppgs` client. Used when creating the clients for the
  separate Graph Modeling services. Part of the `2.6.0` migration. Recommended, alphanumeric value, 32 characters.

- `RECOMMENDER_KEYCLOAK_LOGIN_CLIENTSECRET` - a secret to set for the `recommender` client. Used when creating the
  clients for the separate Graph Modeling services. Part of the `2.6.0` migration. Recommended, alphanumeric value, 32
  characters.

**Change**

- `KC_HOSTNAME` - address at which the Keycloak is exposed.

  Should be set to full URL (incl. the context path `KC_HTTP_RELATIVE_PATH`), when the dynamic backchannel is enabled.
  See `KC_HOSTNAME_BACKCHANNEL_DYNAMIC`.

**Remove**

- `POOLPARTY_KEYCLOAK_LOGIN_CLIENTSECRET` - replaced by specific client secret per application or service (e.g. ppt,
  ppgs, extractor, etc.)

**Migration Specific**

We recommend to use the default values. Modify them, only if required. The configurations are listed for completeness.

- `SUPERADMIN_REQUIRES_ACTIONS` - toggles whether it is required to update the password for the imported Graph Modeling
  admin user. Default values is `true`.

- `AUTO_MIGRATION_ENABLED` - toggles the automatic migration execution on container startup. By default `true`.

- `POOLPARTY_KEYCLOAK_REALM` - target realm identifier for the migration. Default value `poolparty`.

- `TARGET_MIGRATION_VERSION` - target semantic version the orchestrator will attempt to reach. By default the value is
  inferred from container image.

- `KC_BOOTSTRAP_ADMIN_USERNAME` / `KC_BOOTSTRAP_ADMIN_PASSWORD` - fallback support for Keycloak 26+ bootstrap
  credentials, alongside standard `KEYCLOAK_ADMIN` variables.

- `MIGRATION_HEALTH_SIGNAL_FILE` - path of the migration-completed marker consumed by the container healthcheck.
  Default: `/opt/keycloak/data/migration_done`. Can be overridden (e.g., to `/dev/null`) during manual per-realm
  migration executions.

- `MIGRATION_LOG_FILE` - path for the migration log file. Default: `/opt/keycloak/data/migration.log`. It can be useful
  for log isolation during per-realm manual executions.

- `MIGRATIONS_BASE_DIR` - path to the base directory for migration scripts. Default: `/opt/keycloak/migrations`.

- `MIGRATION_TIMEOUT` - readiness wait budget in seconds. Default: `300`. Retained as the default for the two timeouts
  below.

- `MIGRATION_READINESS_TIMEOUT` - time to wait for the Keycloak Admin API to become usable. Default: `MIGRATION_TIMEOUT`

- `MIGRATION_REALM_TIMEOUT` - time to wait for the target realm to become available. Default: `MIGRATION_TIMEOUT`.

- `MIGRATION_SCRIPT_TIMEOUT` - wall-clock cap for a single version migration. Default: `900`.

- `MIGRATION_BASELINE_VERSION` - version assumed for realms, when there is no `migration_version` attribute in the realm
  JSON file. Default: `2.3.0`.

- `MIGRATION_LOG_DEBUG` - toggles the debug log printing (raw kcadm output for tolerated conflicts and failures) to the
  console. Default: `false`.

- `MIGRATION_LOG_MAX_BYTES` - rotates the migration log to `<file>.1` above specific size. Default: `5242880`.

- `MIGRATION_LOCK_DIR` - overrides the per-realm migration lock path. Default: `/tmp/poolparty-migration-<realm>.lock`.

- `MIGRATION_LOCK_TIMEOUT` - seconds to wait for a migration lock held by another run. Default: `600`.

#### Graph Modeling Configuration Changes

**New**

- `POOLPARTY_PPT_KEYCLOAK_LOGIN_CLIENTID` - name of the client for the Taxonomy service. Default: `ppt`.

- `POOLPARTY_PPT_KEYCLOAK_LOGIN_CLIENTSECRET` - secret for the Taxonomy service client. See the
  `PPT_KEYCLOAK_LOGIN_CLIENTSECRET` from the Keycloak configurations section.

- `POOLPARTY_PPGS_KEYCLOAK_LOGIN_CLIENTID` - name of the client for the Graph Search service. Default: `ppgs`.

- `POOLPARTY_PPGS_KEYCLOAK_LOGIN_CLIENTSECRET` - secret for the Graph Search service client. See the
  `PPGS_KEYCLOAK_LOGIN_CLIENTSECRET` from the Keycloak configurations section.

- `POOLPARTY_PPX_KEYCLOAK_LOGIN_CLIENTID` - name of the client for the Extractor service. Default: `extractor`.

- `POOLPARTY_PPX_KEYCLOAK_LOGIN_CLIENTSECRET` - secret for the Extractor service client. See the
  `EXTRACTOR_KEYCLOAK_LOGIN_CLIENTSECRET` from the Keycloak configurations section.

- `POOLPARTY_AUTH_OPENID_REQUIRE_AUDIENCE` - toggles audience mapping validation for more granular access control.
  Default: `false`. Should be set to `true`, only if no addons are used (e.g. ADF, Semantic Workbench, GraphViews, etc.)

**Remove**

- `POOLPARTY_KEYCLOAK_LOGIN_CLIENTID` - replaced by specific client secret per application or service (e.g. ppt, ppgs,
  extractor, etc.)

- `POOLPARTY_KEYCLOAK_LOGIN_CLIENTSECRET` - replaced by specific client secret per application or service (e.g. ppt,
  ppgs, extractor, etc.)

### Step-by-step Migration

Once the configuration properties are adjusted for both Keycloak and Graph Modeling, you can proceed with the migration.
It needs to happen on phases in order to avoid potential errors and issues.

1. It is required to stop the Graph Modeling Pod, while migrating the Keycloak, because there is a additional update
   related to the users, performed by Graph Modeling. 

   The simplest way to do that is by scaling down the Graph Modeling StatefulSet to `0`.

   ```shell
   kubectl scale --replicas=0 statefulset/poolparty
   ```

2. If you are using Keycloak cluster (replicas > 1), it needs to be scaled down to `1` replica. This is required due to
   the way the migration is implemented and work. It is executed as part of the container initialization, meaning that
   if you are using multiple replicas, each of them will try to execute the migration, potentially leading to concurrent
   modification of the underlying database and errors.

   ```shell
   kubectl scale --replicas=1 statefulset/keycloak
   ```

3. Bump the version of the image used for the Keycloak `image: ontotext/poolparty-keycloak:2.6.0` and apply the changes.
   The migration process may take a while, depending on the version from which you are migrating. The process goes
   through versions incrementally and applies the necessary changes.

4. Trace the log during the initialization of the Keycloak to verify that the migration completes successfully.

5. Scale back the Keycloak to the number of replicas you want to use using the same command as in step 2 and modifying
   the `--replicas=<number>` argument.

6. Bump the version of the Graph Modeling `image: ontotext/poolparty:10.3.1` and apply the changes. If needed scale back
   the replicas to `1`.

   ```shell
   kubectl scale --replicas=1 statefulset/poolparty
   ```

   > [!NOTE]
   > There is a known issue with the migration of the Realm Roles. Please check, whether you have role that uses dots
   > `.` in its name. If there are such, the migration of the Graph Modeling will fail. To mitigate that you can pass
   > `POOLPARTY_ROLES_IGNORED` configuration property to Graph Modeling with the name of the role(s) to skip during the
   > process.

7. Trace the log to check for any errors during initialization. If everything completes without any issues related to
   permissions and Keycloak connection, the migration is completed.

8. [Optional] If you are using multiple domains for you environment, make sure to login to Keycloak as an admin and
   update the `Valid redirect URIs` and `Web Origins` for the different clients to allow requests from the additional
   domains.

More details related to the migration are published in the official documentation - [TBD]()

## Helm Chart 0.3.0 (App 10.2)

### Migrating from Elasticsearch version 8.x to version 9.x

Graph Modeler (PoolParty) 10.2 migrates to Elasticsearch 9.x which requires a mandatory migration for old deployments
that still use Elasticsearch version 8.x. You can follow the steps from the official Elasticsearch
documentation
[Prepare to upgrade](https://www.elastic.co/docs/deploy-manage/upgrade/prepare-to-upgrade#prepare-upgrade-from-8.x)

### Configuring Unique Elasticsearch Index Names for Multi-Instance Deployments

> [!NOTE]
> This section is applicable only when multiple PoolParty instances are sharing single Elasticsearch.
> For one-to-one relation, it can be skipped.

Starting with PoolParty 10.2.0 (Helm chart 0.3.x), each PoolParty instance can be configured with its own Elasticsearch
index prefix and/or suffix. This is required only when multiple PoolParty instances share a single Elasticsearch
cluster. Without unique names, all instances would read and write the same indices.

#### New Deployments

For a brand-new deployment that will share an Elasticsearch cluster with other PoolParty instances, set a prefix
and/or suffix before the first startup:

```yaml
configuration:
  properties:
    POOLPARTY_ELASTICSEARCH_INDEX_PREFIX: "instance1-"
    # Optional
    # POOLPARTY_ELASTICSEARCH_INDEX_SUFFIX: ""
```

On first startup PoolParty will create its indices using the configured names (e.g. `instance1-conceptdata`,
`instance1-searchdata`, etc.).

#### Existing Deployments — Enabling a Prefix or Suffix

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

#### Verifying the Migration

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
