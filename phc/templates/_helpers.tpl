{{/*
Expand the name of the chart.
*/}}
{{- define "phc.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "phc.fullname" -}}
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
{{- define "phc.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "phc.labels" -}}
helm.sh/chart: {{ include "phc.chart" . }}
{{ include "phc.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "phc.selectorLabels" -}}
app.kubernetes.io/name: {{ include "phc.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "phc.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "phc.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the secrets variable
*/}}
{{- define "phc.global.secrets" -}}
# **********************
# Application Secrets
# **********************
- name: AES_KEY
  valueFrom:
    secretKeyRef:
      name: phc-secrets
      key: AES_KEY
{{- end }}

{{/*
Create the environments variable
*/}}
{{- define "phc.global.environments" -}}
# **********************
# Global Configuration
# **********************
- name: NODE_ENV
  value: {{ .Values.global.environments.nodeEnv | default "develop" | quote }}
- name: DEBUG
  value: {{ .Values.global.environments.debug | default "clt:*" | quote }}
- name: TIMEOUT
  value: {{ .Values.global.environments.timeout | default "90000" | quote }}
# **********************
# Internationalization
# **********************
- name: LOCALE
  value: {{ .Values.global.environments.locale | default "fa" | quote }}
- name: REGION
  value: {{ .Values.global.environments.region | default "IR" | quote }}
- name: TZ
  value: {{ .Values.global.environments.tz | default "Asia/Tehran" | quote }}
# *****************************
# Security Config
# *****************************
# Google captcha
- name: GOOGLE_CAPTCHA_KEY
  value: {{ .Values.global.environments.google.captcha.key | default "6LclmSUqAAAAAD0-92B1U9R3GH683BVZ0JlTDDf2" | quote }}
- name: GOOGLE_CAPTCHA_SECRET
  value: {{ .Values.global.environments.google.captcha.secret | default "6LclmSUqAAAAAIUVtI3vcLRUmBcqSOb_qYUZhc7q" | quote }}
# *****************************
# Messaging Config
# *****************************
# Kavenegar
- name: KAVENEGAR_SENDERS
  value: {{ .Values.global.environments.kavenegar.senders | quote }}
- name: KAVENEGAR_API_KEY
  value: {{ .Values.global.environments.kavenegar.apiKey | default "2B376A6D594F764F3156304D6C6D44744A7A2F6C584D6942764C7468714A7070" | quote }}
# Melipayamak
- name: MELIPAYAMAK_USER
  value: {{ .Values.global.environments.melipayamak.user | default "9039491657" | quote }}
- name: MELIPAYAMAK_PASS
  value: {{ .Values.global.environments.melipayamak.pass | default "scu#JKtQT94X5w@6" | quote }}
- name: MELIPAYAMAK_FROM
  value: {{ .Values.global.environments.melipayamak.from | default "50002710091657" | quote }}
# *****************************
# Client Config
# *****************************
- name: STRICT_TOKEN
  value: {{ .Values.global.environments.strictToken | default "true" | quote }}
- name: UID
  value: {{ .Values.global.environments.uid | default "6448d5355f9f253a031e9215" | quote }}
- name: CID
  value: {{ .Values.global.environments.cid | default "6448d4122ed1fc913e4d4a5a" | quote }}
- name: APP_ID
  value: {{ .Values.global.environments.appId | default "6448d41b95359de4ea2fb0fd" | quote }}
- name: CLIENT_ID
  value: {{ .Values.global.environments.clientId | default "6448d422740b44bbae58c7f2" | quote }}
- name: CLIENT_SECRET
  value: {{ .Values.global.environments.clientSecret | default "78ceee30eea50df52cf2848c2be3aa3a33d9274c" | quote }}
- name: ROOT_DOMAIN
  value: {{ .Values.global.environments.root.domain | default "wenex.org" | quote }}
- name: ROOT_SUBJECT
  value: {{ .Values.global.environments.root.subject | default "root@wenex.org" | quote }}
- name: PLATFORM_URL
  value: {{ .Values.global.environments.platformUrl | default "http://platform-gateway.wenex-platform.svc.cluster.local" | quote }}
- name: API_KEY
  value: {{ .Values.global.environments.apiKey | default "4U2nh6kBzVvjCoRvxoRiuLXkJAYJ7WR4AM8XnlO0ZZHbKl0zE6Er2iIVupILxPPSJ80cDgXf6XdlcpxeoW9a6qhe4slkh4ETyAHxxIcgdR3djTW0eXNxpgZJplQJu66KbMMa1Nweb61NVqtpJRfjzX5oSPDXe8OEvDSxFJt9KukArf35cvmy8Y5EAYTABLWUrN0t4zqcu1oAhULySiNWdsjryRsayRTBiKJXDyvs2r0mWNUqoXjLEXUPr.5YfPsyCkAZxSsqUYiUOOZE" | quote }}
# Backend
- name: CLIENT_AUTHORIZATION_CQRS
  value: {{ .Values.global.environments.backend.authorizationCqrs | default "1SsUFuq.X67aZIH_C1IjIxezA3/LVIuWc60CGueP@6qBi-MShv" | quote }}
# Frontend
- name: CLIENT_BASE_URL
  value: {{ .Values.global.environments.frontend.baseUrl | default "https://phc.w3x.app" | quote }}
- name: CLIENT_ASSETS_URL
  value: {{ .Values.global.environments.frontend.assetsUrl | default "https://assets.phc.w3x.app" | quote }}
# **********************
# Logging Services
# **********************
# Sentry
- name: SENTRY_DSN
  value: {{ .Values.global.environments.sentry.dsn | default "" | quote }}
- name: SENTRY_MAX_BREADCRUMBS
  value: {{ .Values.global.environments.sentry.maxBreadcrumbs | default "10" | quote }}
- name: SENTRY_TRACES_SAMPLE_RATE
  value: {{ .Values.global.environments.sentry.tracesSampleRate | default "1.0" | quote }}
# **********************
# Storage Services
# **********************
# Redis
- name: REDIS_HOST
  value: {{ .Values.global.environments.redis.host | quote }}
- name: REDIS_PORT
  value: {{ .Values.global.environments.redis.port | default "6379" | quote }}
- name: REDIS_PREFIX
  value: {{ .Values.global.environments.redis.prefix | default "phc" | quote }}
- name: REDIS_PASSWORD
  value: {{ .Values.global.environments.redis.password | quote }}
# Mongo
- name: MONGO_HOST
  value: {{ .Values.global.environments.mongo.host | quote }}
- name: MONGO_DB
  value: {{ .Values.global.environments.mongo.db | default "w3x" | quote }}
- name: MONGO_PREFIX
  value: {{ .Values.global.environments.mongo.prefix | default "phc" | quote }}
- name: MONGO_USER
  value: {{ .Values.global.environments.mongo.user | quote }}
- name: MONGO_PASS
  value: {{ .Values.global.environments.mongo.pass | quote }}
- name: MONGO_QUERY
  value: {{ .Values.global.environments.mongo.query | default "replicaSet=rs0&authSource=admin" | quote }}
# **********************
# Broker Services
# **********************
# Nats
- name: NATS_USER
  value: {{ .Values.global.environments.nats.user | default "phc" | quote }}
- name: NATS_PASS
  value: {{ .Values.global.environments.nats.pass | default "phc" | quote }}
- name: NATS_TIMEOUT
  value: {{ .Values.global.environments.nats.timeout | default "90000" | quote }}
- name: NATS_SERVERS
  value: {{ .Values.global.environments.nats.servers | default "nats://nats.nats.svc.cluster.local:4222" | quote }}
# *****************************
# OAuth Information
# *****************************
# Google
- name: GOOGLE_CLIENT_ID
  value: {{ .Values.global.environments.google.client.id | default "932594562282-gieefbqm3csgj5k1850uivbbhavfj0ta.apps.googleusercontent.com" | quote }}
- name: GOOGLE_CLIENT_SECRET
  value: {{ .Values.global.environments.google.client.secret | default "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" | quote }}
- name: GOOGLE_REDIRECT_URI
  value: {{ .Values.global.environments.google.client.redirectUri | default "https://phc.w3x.app/oauth" | quote }}
# **********************
# Telemetry Services
# **********************
# OpenTelemetry
- name: OTLP_PORT
  value: {{ .Values.global.environments.otlp.port | default "4318" | quote }}
- name: OTLP_HOST
  value: {{ .Values.global.environments.otlp.host | default "localhost" | quote }}
# **********************
# APM Service
# **********************
# Elastic APM
- name: ELASTIC_APM_SERVER_URL
  value: {{ .Values.global.environments.apm.serverUrl | default "https://localhost:8200" | quote }}
- name: ELASTIC_APM_SECRET_TOKEN
  value: {{ .Values.global.environments.apm.secretToken | default "secrettokengoeshere" | quote }}
- name: ELASTIC_APM_VERIFY_SERVER_CERT
  value: {{ .Values.global.environments.apm.verifyServerCert | default "false" | quote }}
{{- end }}
