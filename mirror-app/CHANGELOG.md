# Mirror App Helm Chart Changelog

## Version 1.0.0

### Breaking Changes

- Changes the type of the object used for the Sever Mapping JSON. Now instead of ConfigMap, the chart uses Secret. This
  is done, because the JSON file contains sensitive data.

  Configuration changes:

  `configuration.existingServerMap.configmap` ---> `configuration.existingServerMap.secret`
  `configuration.existingServerMap.configmapKey` ---> `configuration.existingServerMap.secretKey`

## Version 0.1.2

- Bumped the version of the Mirror App image to `2.4.1`.
- Added examples for the `server-map.json` configuration.
- Updated the default value of `configuration.externalUrl` to include the context path of the application.
- Updated couple of things in the `README` file.

## Version 0.1.1

- Fixed an issue with the provisioning of the server configuration.

## Version 0.1.0

- Added initial version of the Mirror App Helm Chart.
