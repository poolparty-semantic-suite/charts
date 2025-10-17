# Helm Chart Repository for the PoolParty Semantic Suite

This is the Helm repository for the all PoolParty Semantic Suite charts.

# Usage

```shell
# add the repository and update
helm repo add poolparty-semantic-suite https://poolparty-semantic-suite.github.io/charts
helm repo update

# list available charts
helm search repo poolparty-semantic-suite

# install a chart, e.g., poolparty
helm install poolparty poolparty-semantic-suite/poolparty
```