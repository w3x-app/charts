{{/*
Expand the name of the chart.
*/}}
{{- define "frontend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "frontend.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "frontend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "frontend.labels" -}}
helm.sh/chart: {{ include "frontend.chart" . }}
{{ include "frontend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "frontend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "frontend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "frontend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "frontend.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the environments variable
*/}}
{{- define "frontend.environments" -}}
- name: NUXT_PUBLIC_API_BASE_URL
  value: {{ .Values.environments.nuxt.public.apiBaseUrl | default "http://health-backend-phc.wenex-client.svc.cluster.local" | quote }}
# *****************************
# Push Information
# *****************************
- name: NUXT_PUBLIC_VAPID_PUBLIC_KEY
  value: {{ .Values.environments.nuxt.public.vapidPublicKey | default "BI6g0d-QKlNp2wWlCsUS8K49Y82Pc302yw5tcjhhMGaGoJsnjfz9uFp1dYjniJZCb62hdmqY32wcge9ieJI9GHw" | quote }}
# *****************************
# Security Services
# *****************************
- name: NUXT_PUBLIC_ALTCHA_CHALLENGE_URL
  value: {{ .Values.environments.nuxt.public.altcha.challengeUrl | default "http://phc-gateway.wenex-phc.svc.cluster.local/challenge" | quote }}
# *****************************
# Client Information
# *****************************
- name: NUXT_PUBLIC_APP_ID
  value: {{ .Values.environments.nuxt.public.appId | default "6448d41b95359de4ea2fb0fd" | quote }}
- name: NUXT_PUBLIC_CLIENT_ID
  value: {{ .Values.environments.nuxt.public.phcId | default "6448d422740b44bbae58c7f2" | quote }}
# MQTT Over WebSocket
- name: NUXT_PUBLIC_MQTT_WS_URL
  value: {{ .Values.environments.nuxt.public.mqttWsUrl | default "ws://localhost:8083/mqtt" | quote }}
# *****************************
# Logging Services
# *****************************
- name: NUXT_PUBLIC_SENTRY_DSN
  value: {{ .Values.environments.nuxt.public.sentry.dsn | quote }}
- name: NUXT_PUBLIC_SENTRY_AUTH
  value: {{ .Values.environments.nuxt.public.sentry.auth | quote }}
{{- if .Values.environments.nuxt.public.google }}
# *****************************
# OAuth Information
# *****************************
# Google
- name: NUXT_PUBLIC_GOOGLE_CLIENT_ID
  value: {{ .Values.environments.nuxt.public.google.phc.id | default "932594562282-gieefbqm3csgj5k1850uivbbhavfj0ta.apps.googleusercontent.com" | quote }}
- name: NUXT_PUBLIC_GOOGLE_CLIENT_SCOPE
  value: {{ .Values.environments.nuxt.public.google.phc.scope | default "https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile" | quote }}
- name: NUXT_PUBLIC_GOOGLE_REDIRECT_URI
  value: {{ .Values.environments.nuxt.public.google.phc.redirectUri | default "http://localhost:3000/oauth" | quote }}
{{- end }}
{{- end }}
