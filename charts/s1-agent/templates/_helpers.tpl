{{- define "statefulset.apiVersion" -}}
{{- if semverCompare ">=1.9-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "apps/v1" -}}
{{- else -}}
{{- print "apps/v1beta1" -}}
{{- end -}}
{{- end -}}

{{- define "daemonset.apiVersion" -}}
{{- if semverCompare ">=1.9-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "apps/v1" -}}
{{- else -}}
{{- print "extensions/v1beta1" -}}
{{- end -}}
{{- end -}}

{{- define "clusterRole.apiVersion" -}}
{{- if semverCompare ">=1.17.0-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "rbac.authorization.k8s.io/v1" -}}
{{- else -}}
{{- print "rbac.authorization.k8s.io/v1beta1" -}}
{{- end -}}
{{- end -}}

{{- define "clusterRoleBindings.apiVersion" -}}
{{- if semverCompare ">=1.17.0-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "rbac.authorization.k8s.io/v1" -}}
{{- else -}}
{{- print "rbac.authorization.k8s.io/v1beta1" -}}
{{- end -}}
{{- end -}}

{{/*
Expand the name of the chart.
*/}}
{{- define "sentinelone.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "sentinelone.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "sentinelone.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "sentinelone.agent.labels" -}}
chart: {{ include "sentinelone.chart" . }}
{{ include "sentinelone.agent.selector.labels" . }}
{{- if .Chart.AppVersion }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}
managed-by: {{ .Release.Service }}
{{- if .Values.agent.labels }}
{{- with .Values.agent.labels }}
{{ tpl (toYaml .) $ }}
{{- end -}}
{{- end -}}
{{- end -}}


{{- define "sentinelone.helper.labels" -}}
chart: {{ include "sentinelone.chart" . }}
{{ include "sentinelone.helper.selector.labels" . }}
{{- if .Chart.AppVersion }}
version: {{ .Chart.AppVersion | quote }}
{{- end }}
managed-by: {{ .Release.Service }}
{{- if .Values.helper.labels }}
{{- with .Values.helper.labels }}
{{ tpl (toYaml .) $ }}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "sentinelone.agent.selector.labels" -}}
app: {{ include "sentinelone.name" . }}
release: {{ .Release.Name }}
component: agent
{{- end -}}

{{- define "sentinelone.helper.selector.labels" -}}
app: {{ include "sentinelone.name" . }}
release: {{ .Release.Name }}
component: helper
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "sentinelone.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{ default (include "sentinelone.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
{{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{- define "agent.fullname" -}}
{{- if .Values.agent.fullnameOverride -}}
{{- .Values.agent.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "agent" .Values.agent.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "helper.fullname" -}}
{{- if .Values.helper.fullnameOverride -}}
{{- .Values.helper.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "helper" .Values.helper.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "preDeleteHook.name" -}}
{{- ( printf "%s-%s" .Release.Name "uninstall-agent-job" ) -}}
{{- end -}}

{{- define "preDeleteHook.enabled" -}}
{{- (eq .Values.configuration.deployment_type "helm") }}
{{- end -}}

{{- define "preDeleteHook.rbac.name" -}}
{{ if eq (include "preDeleteHook.enabled" .) "true" }}
{{- include "preDeleteHook.name" . -}}
{{- end -}}
{{- end -}}

{{- define "argocdPostDeleteHook.enabled" -}}
{{- and
  (eq .Values.configuration.deployment_type "argocd")
  (eq .Values.configuration.argocd.post_delete_hook_enabled "true")
}}
{{- end -}}

{{- define "argocdPostDeleteHook.name" -}}
{{- ( printf "%s-%s" .Release.Name "post-uninstall-agent-job" ) -}}
{{- end -}}

{{- define "agentInjection.name" -}}
{{- ( printf "%s-%s" (include "agent.fullname" .) "injection" ) -}}
{{- end -}}

{{- define "admissionControllers.validating.name" -}}
{{- ( printf "%s-%s" .Release.Name "validating-admission-controller" ) -}}
{{- end -}}

{{- define "site_key.secret.create" -}}
{{- empty .Values.secrets.site_key.value | ternary "" "true" }}
{{- end -}}

{{- define "site_key.secret.name" -}}
{{- if include "site_key.secret.create" . }}
{{- include "agent.fullname" . -}}
{{- else -}}
{{- .Values.secrets.site_key.name -}}
{{- end -}}
{{- end -}}

{{- define "custom_ca.secret.create" -}}
{{- (and .Values.configuration.custom_ca (empty .Values.configuration.custom_ca_name)) | ternary "true" "" -}}
{{- end -}}

{{- define "custom_ca.secret.name" -}}
{{- if include "custom_ca.secret.create" . }}
{{- ( printf "%s-%s" (include "agent.fullname" .) "custom-ca" ) -}}
{{- else -}}
{{- .Values.configuration.custom_ca_name -}}
{{- end -}}
{{- end -}}

{{- define "helper.secret.create" -}}
{{- or (empty .Values.secrets.helper_certificate) (eq .Values.configuration.deployment_type "argocd") | ternary "true" "" }}
{{- end -}}

{{- define "webhooks.enabled" -}}
{{- or .Values.configuration.env.injection.enabled
       .Values.configuration.env.admission_controllers.validating.enabled}}
{{- end -}}

{{- define "helper.secret.name" -}}
{{- if include "helper.secret.create" . }}
{{- include "helper.fullname" . -}}
{{- else -}}
{{- .Values.secrets.helper_certificate -}}
{{- end -}}
{{- end -}}

{{- define "helper.rbac.name" -}}
{{ if .Values.helper.rbac.create }}
{{- include "helper.fullname" . -}}
{{- end -}}
{{- end -}}

{{/*
Generate certificates for helper secret
*/}}
{{- define "helper.certificates" -}}
{{- $altNames := list ( printf "%s" "localhost" ) ( printf "%s" (include "helper.fullname" .) ) ( printf "%s.%s" (include "helper.fullname" .) .Release.Namespace ) ( printf "%s.%s.svc" (include "helper.fullname" .) .Release.Namespace ) -}}
{{- $ca := genCA ( printf "%s ca" .Release.Namespace ) (int .Values.secrets.helper_certificate_expiration_duration) -}}
{{- $caCert := $ca.Cert | b64enc -}}
{{- $cert := genSignedCert ( include "helper.secret.name" . ) nil $altNames (int .Values.secrets.helper_certificate_expiration_duration) $ca -}}
{{- $tlsCert := $cert.Cert | b64enc -}}
{{- $tlsKey := $cert.Key | b64enc -}}
{{- dict "tls.crt" $tlsCert "tls.key" $tlsKey "ca.crt" $caCert | toYaml -}}
{{- end -}}

{{- define "helper_token.secret.create" -}}
{{- empty .Values.secrets.helper_token | ternary "true" "" }}
{{- end -}}

{{- define "helper_token.secret.name" -}}
{{- if include "helper_token.secret.create" . }}
{{- ( printf "%s-%s" (include "helper.fullname" .) "token" ) -}}
{{- else -}}
{{- .Values.secrets.helper_token -}}
{{- end -}}
{{- end -}}

{{/*
Generate server token for helper secret
*/}}
{{- define "helper.token" -}}
{{- randAlphaNum 24 | b64enc | quote -}}
{{- end -}}

{{- define "service.name" -}}
{{- include "helper.fullname" . -}}
{{- end -}}

{{- define "service.port" -}}
{{- print 443 -}}
{{- end -}}

{{- define "service.target_port" -}}
{{- print .Values.configuration.env.helper.ports.target -}}
{{- end -}}

{{- define "helper.full_url" -}}
{{- if .Values.configuration.image.helper -}}
{{ .Values.configuration.image.helper }}
{{- else if .Values.configuration.digest.helper -}}
{{ required "Must set the appropriate registry for agent helper pulling" .Values.configuration.repositories.helper }}@sha256:{{ .Values.configuration.digest.helper }}
{{- else -}}
{{ required "Must set the appropriate registry for agent helper pulling" .Values.configuration.repositories.helper }}:{{ default .Values.configuration.tag.agent .Values.configuration.tag.helper }}
{{- end -}}
{{- end -}}

{{- define "agent.full_url" -}}
{{- if .Values.configuration.image.agent -}}
{{ .Values.configuration.image.agent }}
{{- else if .Values.configuration.digest.agent -}}
{{ required "Must set the appropriate registry for agent image pulling" .Values.configuration.repositories.agent }}@sha256:{{ .Values.configuration.digest.agent }}
{{- else -}}
{{ required "Must set the appropriate registry for agent image pulling" .Values.configuration.repositories.agent }}:{{ required "Must set the appropriate tag/digest for agent image pulling" .Values.configuration.tag.agent }}
{{- end -}}
{{- end -}}

{{- define "agent.container_name" -}}
{{- print "s1-agent" -}}
{{- end -}}

{{/*
Collect a list of all custom certificates to be passed to the agent.
Start with certificates passed with the --set-file option to .Values.configuration.custom_ca_path and continue to check for certificates in files/*.pem.
*/}}
{{- define "agent.certificates" -}}
{{- if .Values.configuration.custom_ca -}}
certificates:
{{- range $index, $data := .Values.configuration.custom_ca_path }}
{{- $name := print $index -}}
{{- if not (hasSuffix ".pem" $name) -}}
{{- $name = print $name ".pem" -}}
{{- end }}
- name: {{ print $name }}
  data: {{ $data | b64enc }}
{{- end -}}
{{- range $path, $_ := .Files.Glob "files/*.pem" }}
- name: {{ base $path }}
  data: {{ $.Files.Get $path | b64enc }}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "agent.common_env" -}}
- name: S1_USE_CUSTOM_CA
  value: "{{ .Values.configuration.custom_ca }}"
- name: S1_HELPER_PORT
  value: "{{ include "service.port" . }}"
{{- if .Values.configuration.proxy }}
- name: S1_MANAGEMENT_PROXY
  value: "{{ default "" .Values.configuration.proxy }}"
{{- end }}
{{- if .Values.configuration.dv_proxy }}
- name: S1_DV_PROXY
  value: "{{ default "" .Values.configuration.dv_proxy }}"
{{- end }}
{{- if kindIs "bool" .Values.configuration.env.agent.heap_trimming_enable }}
- name: S1_HEAP_TRIMMING_ENABLE
  value: "{{ .Values.configuration.env.agent.heap_trimming_enable }}"
{{- end }}
{{- if .Values.configuration.env.agent.heap_trimming_interval }}
- name: S1_HEAP_TRIMMING_INTERVAL
  value: "{{ .Values.configuration.env.agent.heap_trimming_interval }}"
{{- end }}
- name: S1_LOG_LEVEL
  value: "{{ .Values.configuration.env.agent.log_level }}"
- name: S1_WATCHDOG_HEALTHCHECK_TIMEOUT
  value: "{{ .Values.configuration.env.agent.watchdog_healthcheck_timeout }}"
- name: S1_HELPER_HEALTHCHECK_RETRY
  value: "{{ .Values.configuration.env.agent.helper_healthcheck_retry }}"
- name: S1_HELPER_HEALTHCHECK_INTERVAL
  value: "{{ .Values.configuration.env.agent.helper_healthcheck_interval }}"
{{- if kindIs "bool" .Values.configuration.env.agent.fips_enabled }}
- name: S1_FIPS_ENABLED
  value: "{{ .Values.configuration.env.agent.fips_enabled }}"
{{- end }}
{{- if kindIs "bool" .Values.configuration.env.agent.enabled }}
- name: S1_AGENT_ENABLED
  value: "{{ .Values.configuration.env.agent.enabled }}"
{{- end }}
- name: S1_POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: S1_POD_NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
- name: S1_HELPER_CRT
  valueFrom:
    secretKeyRef:
      name: {{ include "helper.secret.name" . }}
      key: tls.crt
    {{- if include "helper.secret.create" . }}
      optional: true
    {{- end }}
- name: S1_HELPER_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ include "helper_token.secret.name" . }}
      key: server-token
    {{- if include "helper_token.secret.create" . }}
      optional: true
    {{- end }}
{{- if and .Values.configuration.env.agent.persistent_dir_removal_upon_installation (eq .Values.configuration.deployment_type "helm") }}
- name: S1_DEPLOYMENT_TIMESTAMP
  value: {{ now | quote }}
- name: S1_DEPLOYMENT_REVISION
  value: "{{ .Release.Revision }}"
{{- end }}
{{- end -}}

{{- define "serverlessOnlyMode" -}}
{{- if (eq .Values.configuration.platform.type "serverless") }}
{{- true }}
{{- else if (eq .Values.configuration.deployment_type "argocd") }}
{{- false }}
{{- else }}
{{- $nodes_counter := 0 }}
{{- $fargate_nodes_counter := 0 }}
{{- $is_fargate_node := false }}
{{- range $index, $node := (lookup "v1" "Node" "" "").items }}
{{- $is_fargate_node = false }}
{{- range $k, $v := $node.metadata.labels }}
{{- if and (eq $k "eks.amazonaws.com/compute-type") (eq $v "fargate") }}
{{- $is_fargate_node = true }}
{{- end -}}
{{- end -}}
{{- $nodes_counter = add $nodes_counter 1 }}
{{- if eq $is_fargate_node true }}
{{- $fargate_nodes_counter = add $fargate_nodes_counter 1 }}
{{- $is_fargate_node = false }}
{{- end -}}
{{- end -}}
{{- eq $nodes_counter $fargate_nodes_counter -}}
{{- end -}}
{{- end -}}

{{- define "bottlerocketNode" -}}
{{- if eq .Values.configuration.platform.type "bottlerocket"}}
true
{{- else -}}
{{- $is_bottlerocket_node := false }}
{{- range $index, $node := (lookup "v1" "Node" "" "").items }}
{{- if contains "Bottlerocket" $node.status.nodeInfo.osImage }}
{{- $is_bottlerocket_node = true }}
{{- end -}}
{{- end -}}
{{ ternary "true" "" $is_bottlerocket_node }}
{{- end -}}
{{- end -}}

{{- define "serverlessAgentContainerOwner" -}}
runAsUser: 0
runAsGroup: 0
runAsNonRoot: false
{{- end -}}

{{- define "serverlessAgentContainer" -}}
- name: "{{ include "agent.container_name" . }}"
  image: "{{ include "agent.full_url" . }}"
  imagePullPolicy: {{ default "IfNotPresent" .Values.configuration.imagePullPolicy }}
  securityContext:
    {{- include "serverlessAgentContainerOwner" . | nindent 4 }}
    capabilities:
      add:
        - AUDIT_WRITE
        - DAC_OVERRIDE
        - FOWNER
        - KILL
        - NET_RAW
        - SETGID
        - SETUID
        - SYS_CHROOT
  resources:
{{ toYaml .Values.agentInjection.resources | indent 4 }}
  env:
{{- include "agent.common_env" . | nindent 2 }}
{{- if include "site_key.secret.name" . }}
  - name: SITE_TOKEN
    valueFrom:
      secretKeyRef:
        name: {{ include "site_key.secret.name" . }}
        key: site-key
{{- end }}
  - name: S1_AGENT_TYPE
    value: "k8s_pod"
  - name: S1_POD_UID
    value: "0"
  - name: S1_POD_GID
    value: "0"
{{- end -}}

{{- define "helper.rbac.annotations" -}}
{{- if and .Values.configuration.env.injection.enabled (eq (include "serverlessOnlyMode" .) "true") }}
"helm.sh/resource-policy": keep
{{- if eq (include "argocdPostDeleteHook.enabled" .) "true" }}
"argocd.argoproj.io/sync-options": Delete=false
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "helperResources" -}}
limits:
{{ toYaml .Values.helper.resources.limits | indent 2 }}
requests:
{{- if .Values.configuration.platform.gke.autopilot }}
{{ toYaml .Values.helper.resources.limits | indent 2 }}
{{- else }}
{{ toYaml .Values.helper.resources.requests | indent 2 }}
{{- end -}}
{{- end -}}

{{- define "agentResources" -}}
{{- $resources := .resources | default .Values.agent.resources -}}
limits:
{{ toYaml $resources.limits | indent 2 }}
{{- if and .Values.configuration.platform.gke.autopilot (not (index $resources.limits "ephemeral-storage")) }}
  ephemeral-storage: 1Gi
{{- end }}
requests:
{{- if .Values.configuration.platform.gke.autopilot }}
{{ toYaml $resources.limits | indent 2 }}
{{- if not (index $resources.requests "ephemeral-storage") }}
  ephemeral-storage: 1Gi
{{- end }}
{{- else }}
{{ toYaml $resources.requests | indent 2 }}
{{- end -}}
{{- end -}}

{{- define "persistentDir" -}}
{{- if .Values.configuration.platform.gke.autopilot }}
{{- "/var/lib/sentinelone" }}
{{- else if eq .Values.configuration.platform.type "talos" }}
{{- default "/host" .Values.configuration.env.agent.host_mount_path }}{{ default "/var/sentinelone" .Values.configuration.env.agent.persistent_dir }}
{{- else }}
{{- default "/host" .Values.configuration.env.agent.host_mount_path }}{{ default "/var/lib/sentinelone" .Values.configuration.env.agent.persistent_dir }}
{{- end }}
{{- end -}}

{{- define "helper.config.name" -}}
{{- printf "%s-%s" (include "helper.fullname" .) "config" -}}
{{- end -}}

{{- define "helper.config" -}}
{{- $helperConfig := dict }}
{{- $_ := set $helperConfig "S1_PLATFORM_TYPE" (.Values.configuration.platform.type | toString) -}}
{{- $_ := set $helperConfig "S1_HELPER_LOG_SIZE" (.Values.configuration.env.helper.log_size | toString) -}}
{{- $_ := set $helperConfig "S1_HELPER_CTL_PORT" (.Values.configuration.env.helper.ports.grpc | toString) -}}
{{- $_ := set $helperConfig "S1_COMMUNICATOR_ENABLED" (printf "%t" .Values.configuration.env.helper.communicator_enabled) -}}
{{- if .Values.configuration.env.helper.communicator_enabled -}}
{{- $_ := set $helperConfig "S1_INVENTORY_ENABLED" (printf "%t" .Values.configuration.env.helper.inventory_enabled) -}}
{{- $_ := set $helperConfig "S1_INVENTORY_ONLY" (printf "%t" .Values.configuration.inventory_only) -}}
{{- $_ := set $helperConfig "S1_MANAGEMENT_PROXY" (default "" .Values.configuration.proxy) -}}
{{- $_ := set $helperConfig "S1_MANAGEMENT_SECURED_PROTOCOL_MODE" (default "enforced" .Values.configuration.env.helper.secured_protocol_mode) -}}
{{- end -}}
{{- if .Values.configuration.env.injection.enabled -}}
{{- $_ := set $helperConfig "S1_NAMESPACE_INJECTION_SELECTORS" (default "" (toJson .Values.agentInjection.selector.namespaceSelector.matchLabels)) -}}
{{- $_ := set $helperConfig "S1_INJECTION_CREATE_SITE_TOKEN_SECRET" (include "site_key.secret.create" .) -}}
{{- end -}}
{{- $_ := set $helperConfig "S1_NDR_ENABLED" (printf "%t" .Values.configuration.env.helper.ndr_enabled) -}}
{{- $_ := set $helperConfig "S1_VALIDATING_ADMISSION_CONTROLLER_ENABLED" (printf "%t" .Values.configuration.env.admission_controllers.validating.enabled) -}}
{{- $_ := set $helperConfig "S1_MUTATING_ADMISSION_CONTROLLER_ENABLED" (printf "%t" false) -}}
{{- $_ := set $helperConfig "S1_CLUSTER_TAGS" (default "" (toJson .Values.configuration.cluster.tags)) -}}
{{- $_ := set $helperConfig "S1_USE_CUSTOM_CA" (printf "%t" .Values.configuration.custom_ca) -}}
{{- $_ := set $helperConfig "S1_EXCLUDE_NON_RUNNING_CONTAINERS" (printf "%t" .Values.configuration.env.helper.exclude_non_running_containers) -}}
{{- $_ := set $helperConfig "S1_EXCLUDE_INIT_CONTAINERS" (printf "%t" .Values.configuration.env.helper.exclude_init_containers) -}}
{{- $helperConfig | toYaml -}}
{{- end -}}

{{- define "agent.app_armor_policy" -}}
{{- if .Values.configuration.platform.gke.autopilot }}
{{- "Unconfined" }}
{{- else }}
{{- .Values.agent.apparmorPolicy }}
{{- end -}}
{{- end -}}

{{- define "agent.secure_computing_profile" -}}
{{- default "Unconfined" .Values.agent.seccompProfile.type -}}
{{- end -}}

{{- define "hooks.uninstallScript" -}}
tar xzf /s1-helper/kubectl.tar.gz -C /;
/s1-helper/kubectl get pods --no-headers --field-selector status.phase=Running -o custom-columns=':metadata.name' |
grep {{ include "helper.fullname" . }} |
  xargs -I _ bash -c 'for i in {1..3}; do
    /s1-helper/kubectl exec _ -- bash -c "touch /s1-helper/uninstall-started && killall -SIGUSR1 s1-helper-app" 2>&1 && exit 0 || sleep 1; done';
for i in {1..2}; do
/s1-helper/kubectl get pods --no-headers --field-selector status.phase=Running -o custom-columns=':metadata.name' |
  grep {{ include "agent.fullname" . }} |
    xargs -P 0 -I % bash -c '
      out=$(for i in {1..3}; do
              timeout 30 /s1-helper/kubectl exec % -- bash -c "
                    sentinelctl control uninstall
                " && exit 0 || sleep 2;
            done;
            exit 1
      ) && echo -e "\nSuccess For Pod %:\n$out" || (echo -e "\nError For Pod %:\n$out" && exit 1)'
if [[ $? == 0 ]]; then break; fi
echo -e "\n----------------------------------\n";
sleep 1;
done;
{{- end -}}
