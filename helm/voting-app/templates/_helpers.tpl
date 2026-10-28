{{- define "voting.labels" -}}
app.kubernetes.io/part-of: voting-app
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
{{- end -}}
