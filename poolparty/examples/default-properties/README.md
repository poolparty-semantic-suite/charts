# Graph Modeling Default Configuration Properties Example

The example in the current directory provides a quick overview of the default properties required for the installation
of the Graph Modeling (ex. PoolParty) in a Kubernetes cluster.

AS you can see, most of the configurations are related to the Graph Modeling direct dependencies (e.g. URLs,
credentials, other secrets).

> [!NOTE]
> The current configuration values are adjusted to work with the rest of the examples from the root directory. It is not
> recommended to use the same values or provide them in such way for any kind of production environment.  
> 
> This examples should be used only for quick PoC, internal test or local environments!

## Usage

To use the example, simply copy the content in a file called for example `values_overrides.yaml` and use it to install
or modify the Graph Modeling:

```shell
# The command assumes you are in the root "/charts" directory of the repository
# and there is a values_overrides.yaml file in the poolparty directory

helm upgrade --install poolparty -n <namespace> --values ./values_overrides.yaml ./poolparty
```

You can modify and/or override other settings as well.
