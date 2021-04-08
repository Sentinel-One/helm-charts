# SentinelOne Helm Charts
This GitHub repository is the official source for SentinelOne's Helm charts.

## Getting Started
To start using our charts, first add this charts repository using the helm command line tool:
```
helm repo add sentinelone https://sentinel-one.github.io/helm-charts/
```

## Use this charts repository
Once you have added this charts repository to your local helm, you can start using it:
```
# List all charts:
helm search repo sentinelone -l
```

```
# Install s1-agent from the online charts repository:
  helm upgrade --install <name> \
    --namespace=<namespace> \
    --set configuration.cluster.name=<your cluster name to report to console> \
    --set secrets.imagePullSecret=<image pull secret name> \
    --set secrets.site_key.value=<your site key> <path to helm chart, or helm chart name>
```
