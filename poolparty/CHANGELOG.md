# PoolParty Helm Chart Changelog

## Version 0.3.0

### Breaking

> [!CAUTION]
> Graph Modeler (PoolParty) 10.2 uses Elasticsearch version 9.x, so you have to migrate any existing
> Elasticsearch deployments to this major version. See the [UPGRADE.md](UPGRADE.md) guide for more information.

### New

- Graph Modeler 10.2 introduces OAuth 2.0 Client Credentials authentication flow between Graph Modeling and GraphDB.
  For new deployments, it's best to use `ontotext/poolparty-keycloak:2.3.0` which includes automatic realm
  provisioning.

### Updates

- Updated Graph Modeler (PoolParty) to
  version [10.2.0](https://help.graphwise.ai/en/graph-modeling/graph-modeling-overview/release-notes/graph-modeling-10-2-release-notes.html)
- Updated the [examples/](examples) to use `ontotext/poolparty-elasticsearch:9.2.4` and
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
