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

{{/*
Defines the internal service address of RDF4J Workbench. 
*/}}
{{- define "rdf4j.service.address"}}
  {{- if .Values.rdf4j.enabled -}}
    {{- if and .Values.rdf4j.service.enabled (not .Values.configuration.rdf4j.url) -}}
      http://{{ include "rdf4j.fullname" . }}-0.{{ include "rdf4j.fullname" . }}.{{ include "unified-views.namespace" . }}:{{ .Values.rdf4j.service.ports.http }}
    {{- else if .Values.configuration.rdf4j.url -}}
      {{- $rdf4jUrl := urlParse .Values.configuration.rdf4j.url }}
      {{- printf "%s://%s" $rdf4jUrl.scheme  $rdf4jUrl.host -}}
    {{- else -}}
      {{- fail "There is no service for the internal RDF4J or external one configured." }}
    {{- end -}}
  {{- end -}}
{{- end -}}
