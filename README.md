# Helm Charts Repository for Graph Modeling part of the Graphwise Platform

This is the Helm charts repository for the all Graph Modeling components.

# Usage

```shell
# add the repository and update
helm repo add graph-modeling-charts https://poolparty-semantic-suite.github.io/charts
helm repo update

# list available charts
helm search repo graph-modeling-charts

# install a chart, e.g., poolparty
helm install graph-modeling graph-modeling-charts/graph-modeling
```
