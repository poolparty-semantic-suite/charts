{{/*
Expand the name of the chart.
*/}}
{{- define "poolparty.name" -}}
  {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "poolparty.fullname" -}}
  {{- if .Values.fullnameOverride }}
    {{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
  {{- else }}
    {{- $name := default .Chart.Name .Values.nameOverride }}
    {{- if contains $name .Release.Name }}
      {{- .Release.Name | trunc 63 | trimSuffix "-" }}
    {{- else }}
      {{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
    {{- end }}
  {{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "poolparty.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "poolparty.labels" -}}
helm.sh/chart: {{ include "poolparty.chart" . }}
{{ include "poolparty.selectorLabels" . }}
app.kubernetes.io/version: {{ coalesce .Values.image.tag .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: poolparty
app.kubernetes.io/part-of: poolparty
{{- if .Values.labels }}
{{ tpl (toYaml .Values.labels) . }}
{{- end }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "poolparty.selectorLabels" -}}
app.kubernetes.io/name: {{ include "poolparty.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use.
*/}}
{{- define "poolparty.serviceAccountName" -}}
  {{- if .Values.serviceAccount.create }}
    {{- default (include "poolparty.fullname" .) .Values.serviceAccount.name }}
  {{- else }}
    {{- default "default" .Values.serviceAccount.name }}
  {{- end }}
{{- end }}

{{/*
Returns the namespace of the release.
*/}}
{{- define "poolparty.namespace" -}}
{{- .Values.namespaceOverride | default .Release.Namespace | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Creates a name for the ConfigMap with the PoolParty Java arguments.
*/}}
{{- define "poolparty.fullname.configmap.environment" -}}
  {{- printf "%s-%s" (include "poolparty.fullname" .) "environment" -}}
{{- end -}}

{{/*
Creates a name for the default ConfigMap with the PoolParty configuration properties.
The properties will be provided as environment variables.
*/}}
{{- define "poolparty.fullname.configmap.properties" -}}
  {{- printf "%s-%s" (include "poolparty.fullname" .) "properties" -}}
{{- end -}}
