{{- define "opentick.name" -}}
{{- .Chart.Name -}}
{{- end -}}

{{- define "opentick.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

