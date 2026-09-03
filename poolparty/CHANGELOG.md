# PoolParty Helm Chart Changelog

## Version 1.0.0

### Migration

> [!CAUTION]
> Graph Modeling (PoolParty) 10.3 now works with new Keycloak image, which contains automated migration.
> For more information on available configurations and migration process, consult the [UPGRADE.md](UPGRADE.md) guide and
> the official documentation at `<<todo: add reference>>`

### Changes

- Updates Graph Modeling (PoolParty) to **10.3.1**. The version contains few improvements, bug fixes and new features.
  Refer to the official Release notes for more details -
  [Graph Modeling Release Notes](https://help.graphwise.ai/en/graph-modeling/graph-modeling-release-notes.html).
    - There are new properties for configuration of the Keycloak clients for the separate services of Graph Modeling.
- Updates the [examples](examples) to use `ontotext/poolparty-elasticsearch:9.3.8`. The new version of Elasticsearch
  contains security patches.
- Updates the Keycloak dependency example to use the latest image `ontotext/poolparty-keycloak:2.6.0`. The new version
  contains:
    - Update of the base image to the latest version of Keycloak `25.x.x`, which provides additional security patches.
    - Automatic migration related to the different applications communication and authentication.
    - New configuration properties related to the migration.
    - Replacement of configuration properties related to the Keycloak service clients.

  For more information about the migration, refer to [UPGRADE.md](UPGRADE.md).
- Removed the default set of settings from the `configuration.properties` section in the `values.yaml`. In most cases
  the default properties are causing issues when merging maps that override some of them.

  We've introduced new example in the [default-properties](./examples/default-properties/) directory, providing details
  about the default set of configurations.

## Version 0.3.3

- Updates Graph Modeling (PoolParty) to **10.2.2**. The version contains couple of important security patches and
  improvements.

## Version 0.3.2

- Updates Graph Modeling (PoolParty) to **10.2.1**. It provides couple of minor bug fixes, UI improvements and security
  patches.

## Version 0.3.1

- Adds value for the license secret for convenience.
- Adds `resources` settings for the `elasticsearch` and `keycloak` manifests in the examples.
- Updates the documentation.

## Version 0.3.0

### Breaking

> [!CAUTION]
> Graph Modeling (PoolParty) 10.2 uses Elasticsearch version 9.x, so you have to migrate any existing
> Elasticsearch deployments to this major version. See the [UPGRADE.md](UPGRADE.md) guide for more information.

### Updates

- Updated Graph Modeling (PoolParty) to
  version [10.2.0](https://help.graphwise.ai/en/graph-modeling/graph-modeling-overview/release-notes/graph-modeling-10-2-release-notes.html)
- Updated the [examples/](examples) to use `ontotext/poolparty-elasticsearch:9.3.3` and
  `ontotext/poolparty-keycloak:2.3.0`

## Version 0.2.3

- Updates the version of the PoolParty to `10.1.2`.

## Version 0.2.2

- Fixes the `resources` section in the chart. We've switched the values for `request` and `limit`.

## Version 0.2.1

- Updates the version of the PoolParty to `10.1.1`.

## Version 0.2.0

- Updates the version of the PoolParty to `10.1.0`.
- Updates the `tempVolume` configuration to support creation of standard volume instead of an `emptyDir`. The default
  behavior is kept, but now the users can switch to standard persistent volume with just a flag.

## Version 0.1.2

- Bumped the required `kubeVersion` for the chart.
- Updated some parts of the documentation.

## Version 0.1.1

- Update PoolParty to version 10.0.2

## Version 0.1.0

- Added initial version of the PoolParty Helm Chart.
