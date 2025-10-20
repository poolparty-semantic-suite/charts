{{/*
Combined image pull secrets.
*/}}
{{- define "rdf4j.combinedImagePullSecrets" -}}
  {{- $secrets := concat .Values.global.imagePullSecrets .Values.image.pullSecrets }}
  {{- tpl (toYaml $secrets) . -}}
{{- end -}}

{{/*
Renders the container image for RDF4J Workbench.
*/}}
{{- define "rdf4j.image" -}}
  {{- $repository := .Values.rdf4j.image.repository -}}
  {{- $tag := .Values.rdf4j.image.tag | toString -}}
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
