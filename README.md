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
helm install s1 --namespace=<namespace> --set image.imagePullSecrets[0].name=<secret> --set helper.image.repository=<helper-image-repository> --set helper.image.tag=<helper-image-tag> --set agent.image.repository=<agent-image-repository> --set agent.image.tag=<agent-image-tag> --set agent.env.site_key=<site-key> sentinelone/s1-agent
```
