{{- define "operately.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "operately.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name (include "operately.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{- define "operately.labels" -}}
app.kubernetes.io/name: {{ include "operately.name" . }}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version | replace "+" "_" }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "operately.selectorLabels" -}}
app.kubernetes.io/name: {{ include "operately.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "operately.postgresql.host" -}}
{{- if .Values.postgresql.enabled -}}
{{- if .Values.postgresql.fullnameOverride -}}
{{ .Values.postgresql.fullnameOverride }}
{{- else -}}
{{ printf "%s-postgresql" .Release.Name }}
{{- end -}}
{{- else -}}
{{- /* fall back unused when external DB */ -}}
{{ printf "%s-postgresql" .Release.Name }}
{{- end -}}
{{- end -}}

{{- define "operately.database.url" -}}
{{- $dbUrl := .Values.db.external.databaseUrl -}}
{{- if and .Values.db.external.enabled $dbUrl }}
{{- $dbUrl -}}
{{- else if and .Values.db.external.enabled (not $dbUrl) -}}
{{- $host := .Values.db.external.host -}}
{{- $port := .Values.db.external.port -}}
{{- $db := .Values.db.external.database -}}
{{- $user := .Values.db.external.username -}}
{{- printf "ecto://%s:%s@%s:%v/%s" $user .Values.db.external.password $host $port $db -}}
{{- else if .Values.postgresql.enabled -}}
{{- $host := include "operately.postgresql.host" . -}}
{{- $port := 5432 -}}
{{- $db := .Values.postgresql.auth.database -}}
{{- $user := .Values.postgresql.auth.username -}}
{{- $pass := .Values.postgresql.auth.password -}}
{{- printf "ecto://%s:%s@%s:%v/%s" $user $pass $host $port $db -}}
{{- else -}}
{{- /* No DB configured; leave empty to surface error */ -}}
{{- "" -}}
{{- end -}}
{{- end -}}
