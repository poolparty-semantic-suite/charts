# GraphViews Helm Chart Changelog

## Version 0.2.1

> [!WARNING]
> The purpose of this patch release is to provide mitigation for the Java4Shell (CVE-2026-114938)!  
> We recommend updating as soon as possible, if your underlying infrastructure is impacted.

- Added `-XX:-UseBASE64Intrinsics` as default Java argument for the container.

## Version 0.2.0

- Updates the GraphViews application version to `1.0.1`. The new version mainly contains security patches.
- Updates the required Kubernetes version from `1.32` to `1.34+`.

## Version 0.1.1

- Updates the default value of the `PP_URL` configuration property for consistency with the rest of the charts.

## Version 0.1.0

- Added initial version of the GraphViews Helm Chart.
