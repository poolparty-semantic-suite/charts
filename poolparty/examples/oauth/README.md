# Graph Modeler and OAuth 2.0

The [values.yaml](values.yaml) example shows the required reconfiguration to enable Client Credentials authentication
flow between Graph Modeler and GraphDB.

## GraphDB

GraphDB needs to be properly configured with the following properties in order for Graph Modeler to authenticate with
Client Credentials:

```properties
security.enabled=true
graphdb.auth.methods=openid
graphdb.auth.database=oauth
graphdb.auth.openid.issuer=<KEYCLOAK_URL>/realms/poolparty
graphdb.auth.openid.client_id=graphdb
graphdb.auth.openid.token_type=access
graphdb.auth.openid.username_claim=preferred_username
graphdb.auth.openid.auth_flow=code
graphdb.auth.openid.token_audience=graphdb
graphdb.auth.openid.require_audience=true
graphdb.auth.oauth.roles_claim=resource_access.graphdb.roles
graphdb.auth.oauth.default_roles=ROLE_USER
```
