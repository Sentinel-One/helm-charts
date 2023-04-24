{{- define "deployment.apiVersion" -}}
{{- if semverCompare ">=1.9-0" .Capabilities.KubeVersion.GitVersion -}}
{{- print "apps/v1" -}}
{{- else -}}
{{- print "extensions/v1beta1" -}}
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

{{- define "agentInjection.name" -}}
{{- ( printf "%s-%s" (include "agent.fullname" .) "injection" ) -}}
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

{{- define "helper.secret.create" -}}
{{- empty .Values.secrets.helper_certificate | ternary "true" "" }}
{{- end -}}

{{- define "helper.secret.name" -}}
{{- if include "helper.secret.create" . }}
{{- include "helper.fullname" . -}}
{{- else -}}
{{- .Values.secrets.helper_certificate -}}
{{- end -}}
{{- end -}}

{{/*
Generate certificates for helper secret
*/}}
{{- define "helper.certificates" -}}
{{- $altNames := list ( printf "%s" "localhost" ) ( printf "%s" (include "helper.fullname" .) ) ( printf "%s.%s" (include "helper.fullname" .) .Release.Namespace ) ( printf "%s.%s.svc" (include "helper.fullname" .) .Release.Namespace ) -}}
{{- $ca := genCA ( printf "%s ca" .Release.Namespace ) 365 -}}
{{- $caCert := $ca.Cert | b64enc -}}
{{- $cert := genSignedCert ( include "helper.secret.name" . ) nil $altNames 365 $ca -}}
{{- $tlsCert := $cert.Cert | b64enc -}}
{{- $tlsKey := $cert.Key | b64enc -}}
{{- dict "tls.crt" $tlsCert "tls.key" $tlsKey "ca.crt" $caCert | toYaml -}}
{{- end -}}

{{- define "service.name" -}}
{{- include "helper.fullname" . -}}
{{- end -}}

{{- define "service.port" -}}
{{- print 443 -}}
{{- end -}}

{{- define "service.target_port" -}}
{{- print 6443 -}}
{{- end -}}

{{- define "helper.full_url" -}}
{{- if .Values.configuration.image.helper -}}
{{ .Values.configuration.image.helper }}
{{- else -}}
{{ required "Must set the appropriate registry for agent helper pulling" .Values.configuration.repositories.helper }}:{{ default .Values.configuration.tag.agent .Values.configuration.tag.helper }}
{{- end -}}
{{- end -}}

{{- define "agent.full_url" -}}
{{- if .Values.configuration.image.agent -}}
{{ .Values.configuration.image.agent }}
{{- else -}}
{{ required "Must set the appropriate registry for agent image pulling" .Values.configuration.repositories.agent }}:{{ required "Must set the appropriate tag for agent image pulling" .Values.configuration.tag.agent }}
{{- end -}}
{{- end -}}

{{/*
Get certificates for custom ca
*/}}
{{- define "custom_certs1" -}}
{{- $ca_paths := .Values.configuration.custom_ca_path -}}
{{- range $index, $path := $ca_paths -}}
{{- printf "cert_%s.pem: %s" $index ($path |b64enc) | toYaml | nindent 2 -}}
{{- end }}
{{- end }}


{{/*
  Helper template to loop through Values.configuration.custom_ca_path and create a list of certificates with their names and data.
  */}}
{{- define "certificates_yaml" -}}
{{ print "certificates:" | nindent 2 }}
{{- range $index, $path := .Values.configuration.custom_ca_path }}
{{- $name := print "cert_" $index ".pem" -}}
  {{ printf "- %s: %s" $name ($path | b64enc) | nindent 4 -}}
  {{/*
  {{ printf "- %s: %s" $name ($path | b64enc) }}
  {{ printf "- %s: |-" $name | nindent 2}}
  {{ $path | nindent 4}}
  */}}
{{- end -}}
{{- end }}


{{/*
{{- define "certificates" -}}
{{- $certificates := .Values.configuration.custom_ca_path -}}
{{- $certificatesMap := dict -}}
{{- range $index, $certificatePath := $certificates }}
{{- $certificatesMap.Set (toString $index) (dict "name" $index "path" $certificatePath) }}
{{- end }}
{{- $certificatesMap }}
{{- end }}
*/}}

{{/*
	Helper function to create a map of certificate data from a list of file paths
	*/}}
{{/*
	{{- define "certificates" -}}
	  {{- $certificatesMap := dict -}}
	  {{- range $index, $path := .Values.configuration.custom_ca_path }}
		{{- $certificatesMap = $certificatesMap | merge (dict (printf "cert-%d" $index) (dict "name" $index "path" $path)) }}
	  {{- end }}
	  {{- $certificatesMap -}}
	{{- end }}
*/}}

{{/*
	Helper template to loop through Values.configuration.custom_ca_path and create a list of certificates with their names and data.
*/}}

{{- define "certificates3" -}}
{{- $certificatesMap := dict -}}
{{- range $index, $path := .Values.configuration.custom_ca_path }}
{{- $name := print "cert_" $index ".pem" -}}
{{- $data := $path | b64enc -}}
{{- $certificatesMap = $certificatesMap | merge (dict "name" $name "data" $data) -}}
{{- end }}
{{- $certificatesMap -}}
{{- end }}

{{- define "ca-certs" }}
{{- $ca_list := list }}
{{- $ca_paths := .Values.configuration.custom_ca_path }}
{{- range $index, $path := $ca_paths }}
{{- $ca_list := append $ca_list (dict "certName" $index "data" (print $path | b64enc)) -}}
{{/*}}
{{- $name := printf "cert_%d" $index }}
{{- $data := $path }}
{{- $ca_list = append $ca_list (dict "name" $name "data" $data) }}
{{- end }}
{{- end }}
{{- $ca_list }} */}}
{{- end}}
{{- $ca_list -}}
{{- end }}

{{/*
  Get certificates for custom ca
*/}}
{{- define "custom_certs" -}}
{{- if .Values.configuration.custom_ca }}
{{- if .Values.configuration.custom_ca_path -}}
{{- range $secretName, $secret := .Values.configuration.custom_ca_path -}}
{{- $certFileName := "" -}}
{{- if gt (len (toString $secretName)) 2 -}}
{{- $certFileName = (print $secretName ".pem") -}}
{{- else -}}
{{- $certFileName = (print "custom_cert_" (toString $secretName) ".pem") -}}
{{- end -}}
- name: {{$certFileName}}
  value: {{ $secret | b64enc}}
{{- end -}}
{{- else -}}
{{- range $path, $_ := .Files.Glob "files/*.pem" -}}
- name: {{base $path}}
  value: {{ $.Files.Get $path | b64enc}}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "certificates" -}}
{{- if .Values.configuration.custom_ca }}
{{- $ca_paths := .Values.configuration.custom_ca_path -}}
{{- range $index, $path := $ca_paths -}}
{{- $name := print $index -}}
{{- if not (hasSuffix $name ".pem") -}}
  {{- $name = print "custom_ca_" $name ".pem" -}}
{{- end -}}
  {{ $name }}: |-
    {{ $path | b64enc }}
{{ end }}
{{- end -}}
{{- end -}}


{{- define "certificates_names" -}}
{{- if .Values.configuration.custom_ca }}
{{- $ca_paths := .Values.configuration.custom_ca_path -}}
{{- range $index, $path := $ca_paths -}}
{{- $name := print $index -}}
{{- if not (hasSuffix $name ".pem") -}}
  {{- $name = print "custom_ca_" $name ".pem" -}}
{{- end -}}
  {{ $name }}: |-
    {{ $path | b64enc }}
{{ end }}
{{- end -}}
{{- end -}}

{{- define "agent.common_env" -}}
- name: S1_USE_CUSTOM_CA
  value: "{{ .Values.configuration.custom_ca }}"
- name: S1_HELPER_PORT
  value: "{{ include "service.port" . }}"
- name: S1_MANAGEMENT_PROXY
  value: "{{ default "" .Values.configuration.proxy }}"
- name: S1_DV_PROXY
  value: "{{ default "" .Values.configuration.dv_proxy }}"
- name: S1_HEAP_TRIMMING_ENABLE
  value: "{{ .Values.configuration.env.agent.heap_trimming_enable }}"
- name: S1_HEAP_TRIMMING_INTERVAL
  value: "{{ .Values.configuration.env.agent.heap_trimming_interval }}"
- name: S1_LOG_LEVEL
  value: "{{ .Values.configuration.env.agent.log_level }}"
- name: S1_WATCHDOG_HEALTHCHECK_TIMEOUT
  value: "{{ .Values.configuration.env.agent.watchdog_healthcheck_timeout }}"
- name: S1_FIPS_ENABLED
  value: "{{ .Values.configuration.env.agent.fips_enabled }}"
{{- end -}}
