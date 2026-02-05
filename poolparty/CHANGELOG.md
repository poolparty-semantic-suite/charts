# PoolParty Helm Chart Changelog

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
