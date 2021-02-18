# How to install helm 3

[ https://helm.sh/docs/intro/install/ ]

```
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh
```

# Helm commands

## Create namespace before running helm
kubectl create namespace <namespace>

## Create image pull secret (only if the cluster doesn't have an access to the repository)
```
kubectl create secret -n <namespace> docker-registry <secret-name> --docker-server=<repository> --docker-username=<username> --docker-password=<personal-access-key> --docker-email=<email>
```

## Update helm charts values.yaml with image pull secret
```
image:
    pullPolicy: IfNotPresent
    imagePullSecrets:
      - name: secret-name          <--- set secret name
    nameOverride: ""
    fullnameOverride: ""
```

## Update helm charts values.yaml to pull image always (in case of using the same tag)
```
image:
    pullPolicy: Always             <--- set 'Always' instead of 'IfNotPresent'
    imagePullSecrets: []
    #  - name: "SECRET"
    nameOverride: ""
    fullnameOverride: ""
```

## Update helm charts values.yaml to pull 'helper' image and set cluster name
```
helper:
  # Specifies whether a helper should be created
  create: true
  # The name of the helper to use.
  # If not set and create is true, a name is generated using the fullname template
  name: s1-helper
  image:
    repository: "S1-HELPER-IMAGE"  <--- set 'helper' image
    tag: "S1-HELPER-IMAGE-TAG"     <--- set 'helper' image tag
  env:
    # The name of the cluster.
    cluster: "CLUSTER_NAME"        <--- set cluster name
```

## Update helm charts values.yaml to pull 'agent' image and set site key
```
agent:
  # Specifies whether an agent should be created
  create: true
  # The name of the agent to use.
  # If not set and create is true, a name is generated using the fullname template
  name: s1-agent
  image:
    repository: "S1-AGENT-IMAGE"   <--- set 'agent' image
    tag: "S1-AGENT-IMAGE-TAG"      <--- set 'agent' image tag
  env:
    # If secrets.create is true, the site token is referred to as a plain text and will be saved as a secret.
    # If secrets.create is false, the site token is referred to as a secret which was
    #    created by the user with the same format as templates/secrets.yaml format and in the right namespace.
    site_key: "SITE_KEY"               <--- set plain text site key or secret name
    management_proxy: "PROXY-ADDRESS"  <--- set management proxy address (optional)
```

## Create yamls without installing them using dry run command
```
helm install <name> --namespace=<namespace> --dry-run --debug ./sentinelone/
```

## Create and install the yamls
```
helm install <name> --namespace=<namespace> ./sentinelone/
```

## Uninstall
```
helm uninstall <name>
```

## Upgrade
```
helm upgrade <name> ./sentinelone/
```

## List of helm installations in all namespaces
```
helm list -A
```

## List of helm installations in namespace
```
helm list -n <namespace>
```

## Rollback
```
helm rollback <name> 1
```
## History
```
helm history <name>
```

# example (./sentinelone is the charts folder)
1. user@ubuntu:/data/sentinel-labs/cwpp_agent/helm_charts$
```
kubectl create namespace mytest
```

2. user@ubuntu:/data/sentinel-labs/cwpp_agent/helm_charts$
```
kubectl create secret -n mytest docker-registry user-github-secret --docker-server=docker.pkg.github.com/sentinel-labs --docker-username=user --docker-password=3e2cf46ed94919b7bbbdd5f875ae98ed9b43b5dd --docker-email=user@sentinelone.com
```

3. user@ubuntu:/data/sentinel-labs/cwpp_agent/helm_charts$
```
Edit sentinelone/values.yaml

   image:
       pullPolicy: IfNotPresent
       imagePullSecrets:
         - name: **user-github-secret**
       nameOverride: ""
       fullnameOverride: ""

      (If you keep using the same tag, you must set 'pullPolicy: Always' to pull the new image)
```

4. user@ubuntu:/data/sentinel-labs/cwpp_agent/helm_charts$
```
Edit sentinelone/values.yaml (helper image and cluster name)

   helper:
      # Specifies whether a helper should be created
      create: true
      # The name of the helper to use.
      # If not set and create is true, a name is generated using the fullname template
      name: s1-helper
      image:
         repository: art.sentinelone.net/shared/s1-helper
         tag: v4.0.0.7
      env:
         # The name of the cluster.
         cluster: "LinuxTeam"
```

5. user@ubuntu:/data/sentinel-labs/cwpp_agent/helm_charts$
```
Edit sentinelone/values.yaml (agent image and plain text site key)

   secrets:
      # Specifies whether secrets should be created
      create: true

   agent:
      # Specifies whether an agent should be created
      create: true
      # The name of the agent to use.
      # If not set and create is true, a name is generated using the fullname template
      name: s1-agent
      image:
         repository: art.sentinelone.net/shared/s1-agent
         tag: v4.0.0.7
      env:
         # If secrets.create is true, the site token will be saved as a secret
         site_key: "vyJ1cmwifiAiaHR0cHM6Ly91c2......mUubmV0IiwgInNpdGVfa2V5IjogImEyNDc1ZGVlOTM5OWJxZDUifQ=="
```

6. user@ubuntu:/data/sentinel-labs/cwpp_agent/helm_charts$
```
Create site key secret:

   Encrypt the site token:
   echo "dyJ1cmwiOiAiaHR0cHM6Ly91c2VhMS.........Q4MTVkZmFkM2ZkZmIif" | base64

   Create site key secret yaml file:
   apiVersion: v1
   kind: Secret
   metadata:
      name: site-key-secret
   namespace: kube-system
   type: Opaque
   data:
      site-key: "ZXlKMWNtd2lPaUFpYUhSMGNI.......R1ZmYTJWNUlqb2dJalUwTURRNE1UVmtabUZrTTJaa1ptSWlmUT09Cg=="

   Apply the site key secret:
   kubectl apply -f site-key-secret.yaml
```

7. user@ubuntu:/data/sentinel-labs/cwpp_agent/helm_charts$
```
Edit sentinelone/values.yaml (agent image and site key secret name)

   secrets:
      # Specifies whether secrets should be created
      create: false

   agent:
      # Specifies whether an agent should be created
      create: true
      # The name of the agent to use.
      # If not set and create is true, a name is generated using the fullname template
      name: s1-agent
      image:
         repository: art.sentinelone.net/shared/s1-agent
         tag: v4.0.0.7
      env:
         # If secrets.create is true, the site token will be saved as a secret
         site_key: site-key-secret
```

8. user@ubuntu:/data/sentinel-labs/cwpp_agent/helm_charts$
```
helm install myhelmtest --namespace=mytest --dry-run --debug ./sentinelone
```

9. user@ubuntu:/data/sentinel-labs/cwpp_agent/helm_charts$
```
helm install myhelmtest --namespace=mytest ./sentinelone

   NAME: myhelmtest
   LAST DEPLOYED: Thu Jan  2 15:52:04 2020
   NAMESPACE: mytest
   STATUS: deployed
   REVISION: 1
```

10. user@ubuntu:/data/sentinel-labs/cwpp_agent/helm_charts$
```
kubectl get pods -n mytest

   NAME                                      READY   STATUS    RESTARTS   AGE
   sentinelone-agent-2xmvw                   1/1     Running   0          5m13s
   sentinelone-agent-2zzgw                   1/1     Running   0          5m13s
   sentinelone-agent-kfvmw                   1/1     Running   0          5m13s
   sentinelone-agent-nl6hr                   1/1     Running   0          5m13s
   s1-helper-56cf7fd4c-tqcjb                 1/1     Running   0          5m13s
```

11. user@ubuntu:/data/sentinel-labs/cwpp_agent/helm_charts$
```
helm list -A

   NAME      	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART            	APP VERSION
   myhelmtest	mytest   	3       	2020-01-02 17:27:30.321243289 +0200 IST	deployed	sentinelone-0.1.0	1.16.0     
   test2    	default  	1       	2020-01-02 12:16:59.073610739 +0200 IST	deployed	sentinelone-0.1.0	1.16.0    
```

12. user@ubuntu:/data/sentinel-labs/cwpp_agent/helm_charts$
```
helm list -n mytest

   NAME      	NAMESPACE	REVISION	UPDATED                                	STATUS  	CHART            	APP VERSION
   myhelmtest	mytest   	1       	2020-01-02 15:52:04.164750197 +0200 IST	deployed	sentinelone-0.1.0	1.16.0    
```

13. user@ubuntu:/data/sentinel-labs/cwpp_agent/helm_charts$
```
helm upgrade myhelmtest --namespace=mytest ./sentinelone

   Release "myhelmtest" has been upgraded. Happy Helming!
   NAME: myhelmtest
   LAST DEPLOYED: Thu Jan  2 16:47:59 2020
   NAMESPACE: mytest
   STATUS: deployed
   REVISION: 2
```

14. user@ubuntu:/data/sentinel-labs/cwpp_agent/helm_charts$
```
helm rollback myhelmtest --namespace=mytest 1

   Rollback was a success! Happy Helming!
```

15. user@ubuntu:/data/sentinel-labs/cwpp_agent/helm_charts$
```
helm uninstall myhelmtest --namespace=mytest

   release "myhelmtest" uninstalled
```

16. user@ubuntu:/data/sentinel-labs/cwpp_agent/helm_charts$
```
kubectl delete namespace mytest

   namespace "mytest" deleted
```