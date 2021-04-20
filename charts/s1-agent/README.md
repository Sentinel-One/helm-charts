# SentinelOne Kubernetes Agent Helm Chart

## Install

### Prerequisites

_When using your own image registry:_

* Push images to your registry and tag with the correct tag

In every case:

* Create a namespace to deploy to; e.g. `kubectl create namespace sentinelone`

* Create an image pull secret to pull the images from the registry, if the cluster does not have access to the repository already. This does apply when you are using S1's container registry.
  E.g., to create an image pull secret called `s1-github-access`:
  ```
  kubectl create secret --namespace sentinelone docker-registry s1-github-access --docker-username=s1customer --docker-password=<the Personal Access Token received from SentinelOne support> 
  ```

### Perform install

* Install or upgrade the agent using the helm chart (`name`=the name you want to use for this deployment):
  ```
  helm upgrade --install <name> \
    --namespace=<namespace> \
    --set configuration.cluster.name=<your cluster name to report to console> \
    --set secrets.imagePullSecret=<image pull secret name> \
    --set secrets.site_key.value=<your site key> <path to helm chart, or helm chart name>
  ```

## Configuration scenarios

### A console with a private CA issued certificate

* Set `configuration.custom_ca` to `true` (e.g. `-- set configuration.custom_ca=true`, or edit your `values.yaml`)
* Copy your CA certificate to `files/ca.pem` (from the root of the chart directory)

## Other Operations

### Dry run: Create yamls without installing them using dry run command
```
helm install <name> --namespace=<namespace> --dry-run --debug <path to helm chart, or helm chart name>
```

### Uninstall
```
helm uninstall --namespace=<namespace> <name>
```

### Upgrade
```
helm upgrade <name> <path to helm chart, or helm chart name>
```

### Rollback
```
helm rollback --namespace=<namespace> <name> 1
```

### History
```
helm history --namepsace=<namespace> <name>
```