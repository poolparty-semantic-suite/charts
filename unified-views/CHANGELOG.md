# UnifiedViews Helm Chart Changelog

## Version 0.1.3

- Bumps the version of the UnifiedViews application to **10.2.2**, which contains fixes for some of the default DPUs.

## Version 0.1.2

- Added few additional settings for the Keycloak SSO in order to ease the integration.
- Updated the `config.properties` file to include specific properties, when the SSO is enabled.
- Updated the name of the SSO secret object to something more descriptive.
- Added minor updates and fixes to the `statefulset.yaml` related to the changes in the secrets.
- Removed the checks for the initialized volumes in the `initContainers`. In certain cases, it prevents some of the
  properties updates.
- Added new `initContainer` which takes care of the RDF4J repository initialization, when it is not available and the
  SSO is enabled. This servers as a workaround for an issue with the fresh UV installations.
- Fixed minor issue with the `initContainer` that waits for the RDF4J availability.
- Updated the handling of the license secret. Now it is required, because the UV will not start, if there is no license.

## Version 0.1.1

- Removed the duplicated `env` section for the initContainers in the UV StatefulSet, which causes issues on
  application initialization.
- Fixed the duplication of the OIDC properties, when constructing the `uv.properties` file.
- Bumped the `kubeVersion` to match the version that the rest of the charts are using.

## Version 0.1.0

- Added initial version of the UnifiedViews Helm Chart.
