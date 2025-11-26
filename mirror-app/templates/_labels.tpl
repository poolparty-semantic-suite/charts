{{/*
Expand the name of the chart.
*/}}
{{- define "mirror-app.name" -}}
  {{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mirror-app.fullname" -}}
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
{{- define "mirror-app.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "mirror-app.labels" -}}
helm.sh/chart: {{ include "mirror-app.chart" . }}
{{ include "mirror-app.selectorLabels" . }}
app.kubernetes.io/version: {{ coalesce .Values.image.tag .Chart.AppVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: mirror-app
app.kubernetes.io/part-of: poolparty
{{- if .Values.labels }}
{{ tpl (toYaml .Values.labels) . }}
{{- end }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "mirror-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "mirror-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use.
*/}}
{{- define "mirror-app.serviceAccountName" -}}
  {{- if .Values.serviceAccount.create }}
    {{- default (include "mirror-app.fullname" .) .Values.serviceAccount.name }}
  {{- else }}
    {{- default "default" .Values.serviceAccount.name }}
  {{- end }}
{{- end }}

{{/*
Returns the namespace of the release.
*/}}
{{- define "mirror-app.namespace" -}}
{{- .Values.namespaceOverride | default .Release.Namespace | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Creates a name for the ConfigMap with additional Gunicorn arguments applied on application start up.
*/}}
{{- define "mirror-app.fullname.configmap.environment" -}}
  {{- printf "%s-%s" (include "mirror-app.fullname" .) "environment" -}}
{{- end -}}

{{/*
Creates a name for the default ConfigMap with the Mirror App configuration properties.
The properties will be provided as environment variables.
*/}}
{{- define "mirror-app.fullname.configmap.properties" -}}
  {{- printf "%s-%s" (include "mirror-app.fullname" .) "properties" -}}
{{- end -}}
