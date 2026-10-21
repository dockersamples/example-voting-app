{{/* Labels applied to every resource */}}
{{- define "voting-app.labels" -}}
app.kubernetes.io/part-of: voting-app
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end }}

{{/* Builds ghcr.io/akpochi/voting-app-<name>:<tag> */}}
{{- define "voting-app.image" -}}
{{ .root.Values.image.registry }}/voting-app-{{ .name }}:{{ .root.Values.image.tag }}
{{- end }}
