{{/*
Combined image pull secrets.
*/}}
{{- define "unified-views.combinedImagePullSecrets" -}}
  {{- $secrets := concat .Values.global.imagePullSecrets .Values.image.pullSecrets }}
  {{- tpl (toYaml $secrets) . -}}
{{- end -}}

{{/*
Renders the container image for UnifiedViews.
*/}}
{{- define "unified-views.image" -}}
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
Renders the external UnifiedViews URL.
*/}}
{{- define "unified-views.external-url" -}}
{{- tpl .Values.configuration.externalUrl . -}}
{{- end -}}

{{/*
Checks for potential issues and prints warning messages.
*/}}
{{- define "unified-views.notes.warnings" -}}
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
