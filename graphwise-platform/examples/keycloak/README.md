# Keycloak Deployment Guide

## Overview
Keycloak is the identity and access management (IAM) solution required by PoolParty.
It serves as the authentication provider, managing users, roles, and tokens used across PoolParty components.

PoolParty uses a **customized Keycloak image** that includes Ontotext-specific extensions and realm configuration.
This ensures that all necessary integration points between Keycloak and PoolParty are available out of the box.

## Important Requirement

In **all** PoolParty deployments you **must** use our custom PoolParty-Keycloak image, which includes required extensions:

👉 **[ontotext/poolparty-keycloak on Docker Hub](https://hub.docker.com/r/ontotext/poolparty-keycloak)**

## Example Setup (Development / Testing)

A minimal Keycloak setup is provided for local or non-production testing.
It’s designed to let you start quickly, not for scaling or secure production use.

### Prerequisites
Before you deploy Keycloak, make sure you have:

- The following [secrets](./secrets) created:
  - `keycloak-initial-admin` — admin username & password
  - `pp-secret` — PoolParty integration secret
  - `keycloak-tls` — TLS certificate and private key for HTTPS

Example:
```bash
kubectl apply -f secrets/
```

## Deployment Steps

### **Step 1: Deploy the Service**
Apply the service definition to expose Keycloak inside the cluster:

```bash
kubectl apply -f service.yaml
```

This creates a `ClusterIP` service (`keycloak-service`) that routes traffic to the Keycloak pod.

---

### **Step 2: Deploy the StatefulSet**
Apply the StatefulSet manifest to start Keycloak:

```bash
kubectl apply -f statefulset.yaml
```

This will:
- Start one Keycloak instance (`replicas: 1`)
- Mount TLS certificates from `keycloak-tls` secret
- Use the PoolParty-specific admin credentials and client secret
- Expose HTTPS on port 8443 and HTTP on 8080

---

### Step 3: Access the Keycloak UI

Since no Ingress is configured in this example, you can use port-forwarding to access the Keycloak admin console locally:

```bash
kubectl port-forward statefulset/keycloak 8443:8443 -n keycloak
```

Then open your browser and visit:

👉 [https://keycloak.127.0.0.1.nip.io:8443](https://keycloak.127.0.0.1.nip.io:8443)

If you’re using a self-signed certificate, your browser will show a warning — you can safely proceed for local testing.



