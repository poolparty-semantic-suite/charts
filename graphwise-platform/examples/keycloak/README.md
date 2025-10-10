# Keycloak Deployment Example

## Overview
This example provides a minimal Keycloak setup intended for development or testing environments.
It lets you start quickly without production-level scaling or security configurations.

The provided [`resources.yaml`](./resources.yaml) file includes:
- A StatefulSet that runs Keycloak
- A Service exposing it on HTTP and HTTPS
- All required Secrets


## Prerequisites
Before deploying, open the `resources.yaml` file and set your credentials and secrets in the following resources:

| Secret Name | Purpose | Notes |
|--------------|----------|-------|
| `keycloak-initial-admin` | Admin username and password | Used for the initial Keycloak login |
| `pp-secret` | PoolParty secret | Required for PoolParty integration |
| `keycloak-tls` | TLS certificate and private key | Must include valid `.crt` and `.key` entries |

> Default values are preconfigured for testing, but credentials and secrets **should be replaced** before any real use.



## Deployment

### 1. Apply the resources
Deploy all components with:

```bash
kubectl apply -f resources.yaml
```

This will create:
- A `ClusterIP` Service named `keycloak-service` for routing HTTP and HTTPS traffic
- A StatefulSet running a single Keycloak instance (`replicas: 1`)
- Mounts for TLS certificates from the `keycloak-tls` Secret
- Environment variables sourced from the provided Secrets for admin and PoolParty integration
- Exposed ports:
  - 8080 → HTTP
  - 8443 → HTTPS

## Accessing the Keycloak UI

Since this example doesn’t configure an Ingress, use port-forwarding to reach the admin console:

```bash
kubectl port-forward statefulset/keycloak 8443:8443 -n keycloak
```

Then open your browser and visit:
👉 [https://keycloak.127.0.0.1.nip.io:8443](https://keycloak.127.0.0.1.nip.io:8443)

If you’re using a self-signed certificate, your browser may warn about the connection — you can safely proceed for local testing.
