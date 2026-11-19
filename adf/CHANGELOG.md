# ADF Helm Chart Changelog

## Version 1.1.1

> [!WARNING]
> The purpose of this patch release is to provide mitigation for the Java4Shell (CVE-2026-114938)!  
> We recommend updating as soon as possible, if your underlying infrastructure is impacted.

- Fixed the name of the argument, used to provide the Java Options to the container.
- Added `-XX:-UseBASE64Intrinsics` as default Java argument for the container.
- Adjusted the value for the `-XX:MaxRAMPercentage` from `95` to `85`.

## Version 1.1.0

- Added `replicas` configuration to control the number of ADF pods in the StatefulSet.

## Version 1.0.1

- Avoid rendering an empty `initContainers` section in the StatefulSet manifest

## Version 1.0.0

> [!CAUTION]
> This version requires configuration changes.

- Bumped the version of the ADF application to `1.9.0`.
- Introduced new properties for communication with Keycloak. Check the [Migration Guide](./UPGRADE.md) or the
  [examples](./examples) for more details.

## Version 0.1.3

- Bumped the version of the ADF application to `1.8.2`.

## Version 0.1.2

- Bumped the version of the ADF application to `1.8.1`.

## Version 0.1.1

- Bumped the required `kubeVersion` for the chart.
- Updated the `README` template and generated content for the actual `README.md` file.
- Added `UPGRADE.md`.

## Version 0.1.0

- Added initial version of the ADF Helm Chart.
