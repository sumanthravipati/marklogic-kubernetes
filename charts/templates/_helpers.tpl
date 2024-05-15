{{/*
Expand the name of the chart.
*/}}
{{- define "marklogic.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
The release name will be used as full name
*/}}
{{- define "marklogic.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "marklogic.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create headless service name for statefulset
*/}}
{{- define "marklogic.headlessServiceName" -}}
{{- include "marklogic.fullname" . }}
{{- end}}


{{/*
Create URL for headless service 
*/}}
{{- define "marklogic.headlessURL" -}}
{{- printf "%s.%s.svc.%s" (include "marklogic.headlessServiceName" .) .Release.Namespace .Values.clusterDomain }}
{{- end}}

{{/*
Common labels
*/}}
{{- define "marklogic.labels" -}}
helm.sh/chart: {{ include "marklogic.chart" . }}
{{ include "marklogic.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{- define "marklogic.annotations" -}}
marklogic.com/group-name: {{ .Values.group.name | quote }}
marklogic.com/group-xdqp-enabled: {{ .Values.group.enableXdqpSsl | quote }}
{{- $bootStrapHost := trim .Values.bootstrapHostName }}
{{- if ne $bootStrapHost "" }}
marklogic.com/cluster-name: {{ .Values.bootstrapHostName }}
{{- else }}
marklogic.com/cluster-name: {{ include "marklogic.fqdn" . }}
{{- end }}
{{- end }}

{{/*
{{- end }}

{{/*
{{- end }}

{{/*
{{- end }}

{{/*
Selector labels
*/}}
{{- define "marklogic.selectorLabels" -}}
app.kubernetes.io/name: {{ include "marklogic.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "marklogic.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "marklogic.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Get the name for secret that is used for auth and managed by the Chart.
*/}}
{{- define "marklogic.authSecretName" -}}
{{- printf "%s-admin" (include "marklogic.fullname" .) }}
{{- end }}

{{/*
Get the secret name to mount to statefulSet.
Use the auth.secretName value if set, otherwise use the name from marklogic.authSecretName.
*/}}
{{- define "marklogic.authSecretNameToMount" -}}
{{- if .Values.auth.secretName }}
{{- .Values.auth.secretName }}
{{- else }}
{{- include "marklogic.authSecretName" . }}
{{- end }}
{{- end }}

{{/*
Fully qualified domain name
*/}}
{{- define "marklogic.fqdn" -}}
{{- printf "%s-0.%s.%s.svc.%s" (include "marklogic.fullname" .) (include "marklogic.headlessServiceName" .) .Release.Namespace .Values.clusterDomain }}
{{- end}}

{{/*
Validate values file
*/}}
{{- define "marklogic.checkInputError" -}}
{{- $fqdn := include "marklogic.fqdn" . }}
{{- if gt (len $fqdn) 64}}
{{- $errorMessage := printf "%s%s%s" "The FQDN: " $fqdn " is longer than 64. Please use a shorter release name and try again."  }}
{{- fail $errorMessage }}
{{- end }}
{{- end }}

{{/*
Name to distinguish marklogic image whether root or rootless
*/}}
{{- define "marklogic.imageType" -}}
{{- if .Values.image.tag | contains "rootless" }}
{{- printf "rootless" }}
{{- else }}
{{- printf "root" }}
{{- end }}
{{- end }}

{{/*
Create the name of the Ingress to use.
*/}}
{{- define "marklogic.ingress" -}}
{{- printf "%s-ingress" (include "marklogic.fullname" .) }}
{{- end }}

{{/*
Name of the HAProxy Service name to use in Ingress.
*/}}
{{- define "marklogic.haproxy.servicename" -}}
{{- printf "%s-haproxy" .Release.Name }}
{{- end }}
