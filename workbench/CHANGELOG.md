# Semantic Workbench Helm Chart Changelog

## Version 1.0.0

> [!CAUTION]
> This version requires configuration changes.

- Bumped the version of the Semantic Workbench application to `2.5.0`.
- Introduced new properties for communication with Keycloak. Check the [Migration Guide](./UPGRADE.md) for more details.
- Removed the default properties from `configuration.properties` section. The configuration values were moved as an
  example. See [examples](examples/) for more details.
- Added value for the license secret for convenience. It conforms with the installation guide and the secret created
  there.

## Version 0.1.3

- Bumped the version of the Semantic Workbench application to `2.4.2`.

## Version 0.1.2

- Bumped the version of the Semantic Workbench application to `2.4.1`.

## Version 0.1.1

- Bumped the required `kubeVersion` for the chart.
- Updated the `README` template and generated content for the actual `README.md` file.
- Unified the names in the chart. There were some inconsistencies, when referring to the application/service.

## Version 0.1.0

- Added initial version of the Semantic Workbench Helm Chart.
