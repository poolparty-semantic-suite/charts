# Graphwise Platform Helm Chart

The current chart is an umbrella for the services and applications that are part of the Graphwise Platform.

It provides resources for deploying:

- PoolParty
- GraphDB
- Elasticsearch
- Keycloak
- PostgreSQL

## Package

To package the chart, the following command should be executed:

```bash
# updates the chart dependencies
helm dependency update

# packages the chart
helm package .
```

## Quick start

To run the chart:

```bash
helm upgrade --install --namespace graphwise-platform --create-namespace graphwise-platform .
```

## Usage

### Configuring Services

## Compatibility Matrix

| Component              | Version |
|------------------------|---------|
| PoolParty              | v10.0   |
| Keycloak Operator      | v25.0.6 |
| CloudNativePG Operator | v1.27.0 |
| GraphDB                | 11.1.1  |
| Elasticsearch          | -       |

#### Keycloak

##### Using the Keycloak Operator Helm Chart

We provide a Helm chart for the [Keycloak Operator](https://www.keycloak.org/guides#operator).
This chart sets up the Keycloak Operator at a version compatible with our custom Keycloak image (currently `v25.0.6`) and installs the required CRDs for running Keycloak CRs.

###### Prerequisites

- Enable the Keycloak Operator deployment in the chart values

You also need to create the following secrets:

**Initial Keycloak admin credentials:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: keycloak-initial-admin
type: Opaque
stringData:
  username: poolparty_auth_admin
  password: admin
```

**PoolParty integration secrets (super admin password and client secret):**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: pp-secret
type: Opaque
stringData:
  password: "poolparty"
  clientSecret: "ohIP3x4XuoCsGDsGlZRvNvO5VN6veFb5"
```

**TLS secret for HTTPS:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: keycloak-tls
  namespace: keycloak
type: kubernetes.io/tls
data:
  tls.crt: <base64-encoded certificate>
  tls.key: <base64-encoded private key>
```

##### Keycloak-Only Deployment

1. Install the Graphwise Platform umbrella chart.
2. Apply the [Keycloak CR](examples/keycloak.yaml).

At this point, Keycloak should be running with the in-cluster H2 database (not recommended for production).

##### Keycloak with PostgreSQL

1. Create a secret for the Keycloak database user (must match the DB owner configured in CNPG):
   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: postgre-db-secret
   type: Opaque
   stringData:
     username: keycloak
     password: secret
   ```

2. Create a secret for the PostgreSQL superuser:
   ```yaml
   apiVersion: v1
   kind: Secret
   metadata:
     name: postgre-superuser-secret
   type: Opaque
   stringData:
     username: postgres # must be `postgres`
     password: secret
   ```

3. Enable the CloudNativePG operator:
   ```yaml
   cloudnative-pg:
     enabled: true
   ```

4. Install the umbrella chart — this will deploy both the Keycloak Operator and CNPG.
5. Apply the [PostgreSQL CR](examples/postgre.yaml).
6. Once Postgres is ready, apply your [Keycloak CR](examples/keycloakWithPostgre.yaml) configured to use Postgres.

##### Standalone Keycloak Deployment

If you don’t want to run the Keycloak Operator and CNPG via our Umbrella Chart, you can configure PoolParty to use
your app instances.

###### IMPORTANT
**In this case you must use our custom PoolParty-Keycloak image, which includes required extensions:**

👉 [ontotext/poolparty-keycloak on Docker Hub](https://hub.docker.com/r/ontotext/poolparty-keycloak)

Disable the operator and CNPG in your values:

```yaml
keycloak-operator:
  enabled: false
cloudnative-pg:
  enabled: false
```

#### Elasticsearch

#### GraphDB

See [values.yaml](values.yaml).

## Uninstalling

```bash
helm uninstall --namespace graphwise-platform graphwise-platform
```
