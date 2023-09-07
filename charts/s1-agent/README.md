# SentinelOne Kubernetes Agent Helm Chart

## Install

### Prerequisites

Push images to your registry and tag with the correct tag

In every case:

* Create a namespace to deploy to; e.g. `kubectl create namespace sentinelone`

* Create an image pull secret to pull the images from the registry, if the cluster does not have access to the repository already.
  E.g., to create an image pull secret called `s1-github-access`:
  ```
  kubectl create secret --namespace sentinelone docker-registry s1-github-access --docker-username=<username> --docker-password=<password>
  ```

### Perform install

* Install or upgrade the agent using the helm chart (`release_name`= the release name for this deployment):
  ```
  helm upgrade --install <release_name> \
    --namespace=<namespace> \
    --set configuration.cluster.name=<your cluster name to report to console> \
    --set secrets.imagePullSecret=<image pull secret name> \
    --set configuration.repositories.agent=<s1-agent repo> \
    --set configuration.tag.agent=<s1-agent tag> \
    --set configuration.repositories.helper=<s1-helper repo> \
    --set configuration.tag.helper=<s1-helper tag> \
    --set secrets.site_key.value=<your site key> <path to helm chart, or helm chart name>
  ```

## Configuration scenarios

### A console with a private CA issued certificate

* Set `configuration.custom_ca` to `true` (e.g. `--set configuration.custom_ca=true`, or edit your `values.yaml`)
* Copy your CA certificate to `files/ca.pem` (from the root of the chart directory)

## Other Operations

### Dry run: Create yamls without installing them using dry run command
```
helm install <release_name> --namespace=<namespace> --dry-run --debug <path to helm chart, or helm chart name>
```

### Uninstall
```
helm uninstall --namespace=<namespace> <release_name>
```

### Upgrade
helm upgrade command:
```
  helm upgrade --install <release_name> \
    --namespace=<namespace> \
    --set configuration.cluster.name=<your cluster name to report to console> \
    --set secrets.imagePullSecret=<image pull secret name> \
    --set configuration.repositories.agent=<s1-agent repo> \
    --set configuration.tag.agent=<s1-agent tag> \
    --set configuration.repositories.helper=<s1-helper repo> \
    --set configuration.tag.helper=<s1-helper tag> \
    --set secrets.site_key.value=<your site key> <path to helm chart, or helm chart name>
```
To reuse values:
```
  helm get values <release_name> -n <namespace> -o yaml > deployed_values.yaml
  helm upgrade --install <release_name> --namespace=<namespace> -f deployed_values.yaml \
    --set configuration.tag.agent=<s1-agent tag> \
    --set configuration.tag.helper=<s1-helper tag> \
    <path to helm chart, or helm chart name>
```

### Rollback
```
helm rollback --namespace=<namespace> <release_name> <release version>
```

### History
```
helm history --namepsace=<namespace> <release_name>
```