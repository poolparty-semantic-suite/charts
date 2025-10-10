# Keycloak

## Overview
Keycloak is the Identity and Access Management solution required by PoolParty.
It serves as the central authentication provider, managing users, roles, and tokens across all PoolParty components.

PoolParty uses a **custom Keycloak image** that includes all required extensions and preconfigured realm settings.
This ensures that integration between PoolParty and Keycloak works seamlessly out of the box.

## Setup Requirements

### ⚠️ Important
In **all PoolParty deployments**, you **must use our custom Keycloak image**:

👉 **[ontotext/poolparty-keycloak on Docker Hub](https://hub.docker.com/r/ontotext/poolparty-keycloak)**

This image contains:
- Required PoolParty Keycloak extensions
- Predefined realm configuration for the PoolParty platform

## Container Flags

When running the container, make sure to set the appropriate startup flags:

| Flag | Description |
|------|--------------|
| `start` | Standard startup command for production use |
| `--import-realm` | Imports the PoolParty realm configuration on startup |

> Typically, `--import-realm` is used during initial setup or when provisioning a new environment.

## Environment Variables

The following environment variables must be configured:

| Variable | Description |
|-----------|--------------|
| `POOLPARTY_SUPER_ADMIN_PASSWORD` | PoolParty super admin credentials |
| `POOLPARTY_KEYCLOAK_LOGIN_CLIENTSECRET` | PoolParty realm client secret for Keycloak integration |

> These values are required for PoolParty–Keycloak communication and must be securely stored in Kubernetes Secrets or environment configurations.

## Database Configuration

In production environments, Keycloak should use an external database to persist users, sessions, and realm data.
PostgreSQL is the recommended option — it’s supported natively by Keycloak and can be easily deployed via operators such as [CNPG](https://cloudnative-pg.io/).

## Example

You can refer to our [example Keycloak deployment](./examples/keycloak) for a basic Keycloak setup.

### Notes

This example configuration is **not production-ready**.
For production deployments, make sure to:
- Use an external database (e.g., PostgreSQL)
- Add an Ingress with proper TLS management
- Harden security and resource limits for the Keycloak container

