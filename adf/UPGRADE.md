# Migration Guide

## Upgrading ADF 1.8.x -> 1.9 (Helm chart 0.1.x -> 1.0.0)

The new version of ADF **1.9** introduces new properties for communication between the application and Keycloak -
`KEYCLOAK_PUBLIC_URL` and `KEYCLOAK_INTERNAL_URL`. They are effectively replacing the deprecated `KEYCLOAK_URL`, which
is kept for backwards compatibility.

The new properties are used to separate the browser login flow and internal (backchannel) requests, making the
communication more efficient.

**New**

`KEYCLOAK_PUBLIC_URL` - should provide the public address of the Keycloak and it is used when the ADF is accessed
                        through the browser.

`KEYCLOAK_INTERNAL_URL` - should provide the internal address of the Keycloak in the Kubernetes cluster and it is used
                          for internal (M2M) calls and token validations.

**Deprecated**

`KEYCLOAK_URL` - used to provide the public address for Keycloak. When both of the new configurations are provided, this
                 one can be omitted. 
