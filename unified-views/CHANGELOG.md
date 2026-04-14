# UnifiedViews Helm Chart Changelog

## Version 0.1.1

- Removed the duplicated `env` section for the initContainers in the UV StatefulSet, which causes issues on
  application initialization.
- Fixed the duplication of the OIDC properties, when constructing the `uv.properties` file.
- Bumped the `kubeVersion` to match the version that the rest of the charts are using.

## Version 0.1.0

- Added initial version of the UnifiedViews Helm Chart.
