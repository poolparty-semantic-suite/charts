{{/*
Combined image pull secrets.
*/}}
{{- define "semantic-workbench.combinedImagePullSecrets" -}}
  {{- $secrets := concat .Values.global.imagePullSecrets .Values.image.pullSecrets }}
  {{- tpl (toYaml $secrets) . -}}
{{- end -}}

{{/*
Renders the container image for semantic-workbench.
*/}}
{{- define "semantic-workbench.image" -}}
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
Renders the external semantic-workbench URL.
*/}}
{{- define "semantic-workbench.external-url" -}}
{{- tpl .Values.configuration.externalUrl . -}}
{{- end -}}

{{/*
Checks for potential issues and prints warning messages.
*/}}
{{- define "semantic-workbench.notes.warnings" -}}
  {{- $warnings := list -}}
  {{- if not .Values.persistence.enabled -}}
    {{- $warnings = append $warnings "WARNING: Persistence is disabled! You will lose your data when semantic-workbench pods are restarted or terminated!" -}}
  {{- end -}}
  {{- if not .Values.license.existingSecret -}}
    {{- $warnings = append $warnings "WARNING: You are deploying semantic-workbench without a license! You should obtain one before trying again." -}}
  {{- end -}}
  {{- if gt (len $warnings) 0 }}
    {{- print "\n" }}
    {{- range $warning, $index := $warnings }}
{{ print $index }}
    {{- end }}
  {{- end }}
{{- end -}}
