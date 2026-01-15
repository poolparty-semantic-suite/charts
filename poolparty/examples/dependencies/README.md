# Dependencies

This directory contains the minimal yaml manifests to deploy Keycloak and Elasticsearch in a way to be suitable for use
by PoolParty.

Both examples use Graphwise provided images that have all dependencies pre-installed.

## Elasticsearch

PoolParty needs an Elasticsearch instance at version 8.x with the
[MAT](https://www.elastic.co/docs/reference/elasticsearch/plugins/mapper-annotated-text) plugin installed. The
[ontotext/poolparty-elasticsearch](https://hub.docker.com/r/ontotext/poolparty-elasticsearch) can be used.

## Keycloak

PoolParty requires a Keycloak at version 25.0. The
[ontotext/poolparty-keycloak](https://hub.docker.com/r/ontotext/poolparty-keycloak) image must be used because it also
installs extension, needed by PoolParty, as well as a custom login theme and a realm json file used to provision the
PoolParty realm.

### Import Realm

If the image is started with the `--import-realm` flag, and the master realm hasn't been provisioned yet, Keycloak will
import the PoolParty realm.

The json file has environment variable placeholders that are used to provide different values, various secrets and names.
Check the example yaml file for the available variables.
