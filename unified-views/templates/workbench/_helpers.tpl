{{/*
Combined image pull secrets.
*/}}
{{- define "rdf4j.combinedImagePullSecrets" -}}
  {{- $secrets := concat .Values.global.imagePullSecrets .Values.image.pullSecrets }}
  {{- tpl (toYaml $secrets) . -}}
{{- end -}}

{{/*
Renders the container image for UnifiedViews.
*/}}
{{- define "rdf4j.image" -}}
  {{- $repository := .Values.rdf4j.image.repository -}}
  {{- $tag := .Values.rdf4j.image.tag | default .Chart.AppVersion | toString -}}
  {{- $image := printf "%s:%s" $repository $tag -}}
  {{/* Add registry if present */}}
  {{- $registry := .Values.global.imageRegistry | default .Values.rdf4j.image.registry -}}
  {{- if $registry -}}
    {{- $image = printf "%s/%s" $registry $image -}}
  {{- end -}}
  {{/* Add SHA digest if provided */}}
  {{- if .Values.rdf4j.image.digest -}}
    {{- $image = printf "%s@%s" $image .Values.rdf4j.image.digest -}}
  {{- end -}}
  {{- $image -}}
{{- end -}}

{{/*
Renders the external UnifiedViews URL.
*/}}
{{- define "rdf4j.external-url" -}}
{{- tpl .Values.configuration.externalUrl . -}}
{{- end -}}

{{/*
Checks for potential issues and prints warning messages.
*/}}
{{- define "rdf4j.notes.warnings" -}}
  {{- $warnings := list -}}
  {{- if not .Values.persistence.enabled -}}
    {{- $warnings = append $warnings "WARNING: Persistence is disabled! You will lose your data when UnifiedViews pods are restarted or terminated!" -}}
  {{- end -}}
  {{- if not .Values.license.existingSecret -}}
    {{- $warnings = append $warnings "WARNING: You are deploying UnifiedViews without a license! You should obtain one before trying again." -}}
  {{- end -}}
  {{- if gt (len $warnings) 0 }}
    {{- print "\n" }}
    {{- range $warning, $index := $warnings }}
{{ print $index }}
    {{- end }}
  {{- end }}
{{- end -}}
