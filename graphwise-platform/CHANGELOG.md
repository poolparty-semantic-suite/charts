# Graphwise Platform Helm Chart Release Notes

## Version 1.0.0-alpha

### New

- Introduced the initial version of the Graphwise Platform Helm Chart.

  The Platform consists of the following components:

    - PoolParty
    - GraphDB

  Currently the PoolParty depends on additional components, which have to be provided or already present. These
  components are:

    - Keycloak - for securing the PoolParty instance.
      - Postgresql - as one of the options for external database for Keycloak.
    - Elasticsearch - for indexing of the data used by PoolParty.
  
  Note that there are specific images for Keycloak and Elasticsearch, which contain additional plugins and some
  customizations related to the PoolParty.

  The images are publicly available:

    - Keycloak - https://hub.docker.com/r/ontotext/poolparty-keycloak
    - Elasticsearch - https://hub.docker.com/r/ontotext/poolparty-elasticsearch
