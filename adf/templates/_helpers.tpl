{{/*
Combined image pull secrets.
*/}}
{{- define "adf.combinedImagePullSecrets" -}}
  {{- $secrets := concat .Values.global.imagePullSecrets .Values.image.pullSecrets }}
  {{- tpl (toYaml $secrets) . -}}
{{- end -}}

{{/*
Renders the container image for ADF.
*/}}
{{- define "adf.image" -}}
  {{- $repository := .Values.image.repository -}}
  {{- $tag := .Values.image.tag | default .Chart.AppVersion | toString -}}
  {{- $image := printf "%s:%s" $repository $tag -}}
  {{/* Add registry if present */}}
  {{- $registry := .Values.global.imageRegistry | default .Values.image.registry -}}
  {{- if $registry -}}
    {{- $image = printf "%s/%s" $registry $image -}}
  {{- end -}}
  {{/* Add SHA digest if provided */}}
  {{- if .Values.image.digest -}}
    {{- $image = printf "%s@%s" $image .Values.image.digest -}}
  {{- end -}}
  {{- $image -}}
{{- end -}}

{{/*
Renders the external ADF URL.
*/}}
{{- define "adf.external-url" -}}
{{- tpl .Values.configuration.externalUrl . -}}
{{- end -}}

{{/*
Checks for potential issues and prints warning messages.
*/}}
{{- define "adf.notes.warnings" -}}
  {{- $warnings := list -}}
  {{- if not .Values.persistence.enabled -}}
    {{- $warnings = append $warnings "WARNING: Persistence is disabled! You will lose your data when ADF pods are restarted or terminated!" -}}
  {{- end -}}
  {{- if gt (len $warnings) 0 }}
    {{- print "\n" }}
    {{- range $warning, $index := $warnings }}
{{ print $index }}
    {{- end }}
  {{- end }}
{{- end -}}
