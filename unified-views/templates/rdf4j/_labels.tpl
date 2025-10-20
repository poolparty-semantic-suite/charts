{{/*
Expand the name of the chart.
*/}}
{{- define "rdf4j.name" -}}
  {{- default .Chart.Name "rdf4j-workbench" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "rdf4j.fullname" -}}
  {{- printf "rdf4j" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "rdf4j.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "rdf4j.chartName" -}}
  {{- printf "rdf4j-workbench"}}
{{- end }}

{{/*
Common labels.
*/}}
{{- define "rdf4j.labels" -}}
helm.sh/chart: {{ include "rdf4j.chart" . }}
{{ include "rdf4j.selectorLabels" . }}
app.kubernetes.io/version: {{ .Values.rdf4j.image.tag | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/component: rdf4j
app.kubernetes.io/part-of: unified-views
{{- if .Values.labels }}
{{ tpl (toYaml .Values.labels) . }}
{{- end }}
{{- end }}

{{/*
Selector labels.
*/}}
{{- define "rdf4j.selectorLabels" -}}
app.kubernetes.io/name: {{ include "rdf4j.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use.
*/}}
{{- define "rdf4j.serviceAccountName" -}}
  {{- if .Values.serviceAccount.create }}
    {{- default (include "rdf4j.fullname" .) .Values.serviceAccount.name }}
  {{- else }}
    {{- default "default" .Values.serviceAccount.name }}
  {{- end }}
{{- end }}

{{/*
Returns the namespace of the release.
*/}}
{{- define "rdf4j.namespace" -}}
{{- .Values.namespaceOverride | default .Release.Namespace | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Creates a name for the ConfigMap with the UnifiedViews Java arguments.
*/}}
{{- define "rdf4j.fullname.configmap.environment" -}}
  {{- printf "%s-%s" (include "rdf4j.fullname" .) "environment" -}}
{{- end -}}
