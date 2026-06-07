{{/*
Expand the name of the chart.
*/}}
{{- define "hai.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "hai.fullname" -}}
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
{{- define "hai.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "hai.labels" -}}
helm.sh/chart: {{ include "hai.chart" . }}
{{ include "hai.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "hai.selectorLabels" -}}
app.kubernetes.io/name: {{ include "hai.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "hai.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "hai.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the configuration variables
*/}}
{{- define "hai.global.configuration" -}}
{{- $configuration := .Values.global.configuration | default dict -}}
{{- range $service := keys $configuration | sortAlpha }}
{{- $config := index $configuration $service }}
- name: {{ $service | upper }}_HOST
  value: {{ $config.host | quote }}
- name: {{ $service | upper }}_API_PORT
  value: {{ $config.api | default "80" | quote }}
{{- end }}
{{- end }}

{{/*
Create the secrets variable
*/}}
{{- define "hai.global.secrets" -}}
# **********************
# Application Secrets
# **********************
- name: AES_KEY
  valueFrom:
    secretKeyRef:
      name: hai-secrets
      key: AES_KEY
# **********************
# Captcha Services
# **********************
# Altcha
- name: ALTCHA_HMAC_KEY
  valueFrom:
    secretKeyRef:
      name: hai-secrets
      key: HMAC_KEY
{{- end }}

{{/*
Create the environments variable
*/}}
{{- define "hai.global.environments" -}}
- name: APP_VERSION
  value: {{ .Values.global.image.tag | quote }}
# **********************
# Global Configuration
# **********************
- name: NODE_ENV
  value: {{ .Values.global.environments.nodeEnv | default "develop" | quote }}
- name: DEBUG
  value: {{ .Values.global.environments.debug | default "clt:*" | quote }}
- name: TIMEOUT
  value: {{ .Values.global.environments.timeout | default "90000" | quote }}
- name: GRAPHQL_MUTATION_SUPPORT
  value: {{ .Values.global.environments.graphqlMutationSupport | quote }}
# **********************
# Internationalization
# **********************
- name: LOCALE
  value: {{ .Values.global.environments.locale | default "en" | quote }}
- name: REGION
  value: {{ .Values.global.environments.region | default "IR" | quote }}
- name: TZ
  value: {{ .Values.global.environments.tz | default "Asia/Tehran" | quote }}
# *****************************
# Messaging Config
# *****************************
# Kavenegar
- name: KAVENEGAR_SENDERS
  value: {{ .Values.global.environments.kavenegar.senders | quote }}
- name: KAVENEGAR_API_KEY
  value: {{ .Values.global.environments.kavenegar.apiKey | quote }}
# Melipayamak
- name: MELIPAYAMAK_USER
  value: {{ .Values.global.environments.melipayamak.user | quote }}
- name: MELIPAYAMAK_PASS
  value: {{ .Values.global.environments.melipayamak.pass | quote }}
- name: MELIPAYAMAK_FROM
  value: {{ .Values.global.environments.melipayamak.from | quote }}
# **********************
# AI Config
# **********************
{{- $env := .Values.global.environments | default dict }}
- name: AI_DEFAULT_PROVIDER
  value: {{ dig "ai" "defaultProvider" (dig "llm" "provider" "" $env) $env | quote }}
- name: AI_DEFAULT_CHAT_MODEL
  value: {{ dig "ai" "defaultChatModel" (dig "ollama" "chatModel" "" $env) $env | quote }}
- name: AI_DEFAULT_EMBEDDING_MODEL
  value: {{ dig "ai" "defaultEmbeddingModel" (dig "ollama" "embeddingModel" "" $env) $env | quote }}
- name: AI_DEFAULT_RERANK_PROVIDER
  value: {{ dig "ai" "defaultRerankProvider" "" $env | quote }}
- name: AI_DEFAULT_RERANK_MODEL
  value: {{ dig "ai" "defaultRerankModel" "" $env | quote }}
- name: LLM_PROVIDER
  value: {{ dig "llm" "provider" (dig "ai" "defaultProvider" "" $env) $env | quote }}
- name: LLM_FALLBACK_PROVIDER
  value: {{ dig "llm" "fallbackProvider" "" $env | quote }}
- name: LLM_FALLBACK_OPERATIONS
  value: {{ dig "llm" "fallbackOperations" "" $env | quote }}
- name: SHARIF_LLM_BASE_URL
  value: {{ dig "sharifLlm" "baseUrl" (dig "sharif" "baseUrl" "" $env) $env | quote }}
{{- with (dig "sharifLlm" "bearerToken" "" $env) }}
- name: SHARIF_LLM_BEARER_TOKEN
  value: {{ . | quote }}
{{- end }}
- name: SHARIF_BASE_URL
  value: {{ dig "sharif" "baseUrl" (dig "sharifLlm" "baseUrl" "" $env) $env | quote }}
- name: SHARIF_API_KEY
  value: {{ dig "sharif" "apiKey" (dig "sharifLlm" "bearerToken" "" $env) $env | quote }}
- name: SHARIF_CHAT_MODELS
  value: {{ dig "sharif" "chatModels" "" $env | quote }}
- name: SHARIF_EMBEDDING_MODELS
  value: {{ dig "sharif" "embeddingModels" "" $env | quote }}
- name: SHARIF_RERANK_MODELS
  value: {{ dig "sharif" "rerankModels" "" $env | quote }}
- name: CHATGPT_BASE_URL
  value: {{ dig "chatgpt" "baseUrl" "https://api.openai.com" $env | quote }}
- name: CHATGPT_API_KEY
  value: {{ dig "chatgpt" "apiKey" "" $env | quote }}
- name: CHATGPT_CHAT_MODELS
  value: {{ dig "chatgpt" "chatModels" "" $env | quote }}
- name: CHATGPT_EMBEDDING_MODELS
  value: {{ dig "chatgpt" "embeddingModels" "" $env | quote }}
- name: CHATGPT_RERANK_MODELS
  value: {{ dig "chatgpt" "rerankModels" "" $env | quote }}
- name: OLLAMA_BASE_URL
  value: {{ dig "ollama" "baseUrl" "" $env | quote }}
- name: OLLAMA_CHAT_MODEL
  value: {{ dig "ollama" "chatModel" "" $env | quote }}
- name: OLLAMA_EMBEDDING_MODEL
  value: {{ dig "ollama" "embeddingModel" "" $env | quote }}
- name: OLLAMA_CHAT_MODELS
  value: {{ dig "ollama" "chatModels" (dig "ollama" "chatModel" "" $env) $env | quote }}
- name: OLLAMA_EMBEDDING_MODELS
  value: {{ dig "ollama" "embeddingModels" (dig "ollama" "embeddingModel" "" $env) $env | quote }}
- name: OLLAMA_RERANK_MODELS
  value: {{ dig "ollama" "rerankModels" "" $env | quote }}
{{- with (dig "rag" "provider" "" $env) }}
- name: RAG_PROVIDER
  value: {{ . | quote }}
{{- end }}
- name: RAG_EMBEDDING_MODEL
  value: {{ dig "rag" "embeddingModel" "" $env | quote }}
- name: RAG_ASK_LIMIT
  value: {{ dig "rag" "askLimit" "" $env | quote }}
{{- with (dig "rag" "ollama" "chatModel" "" $env) }}
- name: RAG_OLLAMA_CHAT_MODEL
  value: {{ . | quote }}
{{- end }}
{{- with (dig "rag" "ollama" "embeddingModel" "" $env) }}
- name: RAG_OLLAMA_EMBEDDING_MODEL
  value: {{ . | quote }}
{{- end }}
# *****************************
# Client Config
# *****************************
- name: STRICT_TOKEN
  value: {{ .Values.global.environments.strictToken | default "true" | quote }}
- name: UID
  value: {{ .Values.global.environments.uid | quote }}
- name: CID
  value: {{ .Values.global.environments.cid | quote }}
- name: APP_ID
  value: {{ .Values.global.environments.appId | quote }}
- name: CLIENT_ID
  value: {{ .Values.global.environments.clientId | quote }}
- name: CLIENT_SECRET
  value: {{ .Values.global.environments.clientSecret | quote }}
- name: ROOT_DOMAIN
  value: {{ .Values.global.environments.root.domain | default "hai.behayand.ir" | quote }}
- name: ROOT_SUBJECT
  value: {{ .Values.global.environments.root.subject | default "root@hai.behayand.ir" | quote }}
- name: PLATFORM_URL
  value: {{ .Values.global.environments.platformUrl | default "http://localhost:3010" | quote }}
# Backend
- name: CLIENT_AUTHORIZATION_CQRS
  value: {{ .Values.global.environments.backend.authorizationCqrs | quote }}
- name: API_KEY
  value: {{ .Values.global.environments.apiKey | quote }}
# Frontend
- name: CLIENT_BASE_URL
  value: {{ .Values.global.environments.frontend.baseUrl | default "http://localhost:3005" | quote }}
- name: CLIENT_ASSETS_URL
  value: {{ .Values.global.environments.frontend.assetsUrl | default "http://localhost:8088" | quote }}
# **********************
# Logging Services
# **********************
# Sentry
- name: SENTRY_DSN
  value: {{ .Values.global.environments.sentry.dsn | quote }}
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
  value: {{ .Values.global.environments.redis.prefix | default "hai" | quote }}
- name: REDIS_PASSWORD
  value: {{ .Values.global.environments.redis.password | quote }}
# Mongo
- name: MONGO_HOST
  value: {{ .Values.global.environments.mongo.host | quote }}
- name: MONGO_DB
  value: {{ .Values.global.environments.mongo.db | default "client" | quote }}
- name: MONGO_PREFIX
  value: {{ .Values.global.environments.mongo.prefix | default "hai" | quote }}
- name: MONGO_USER
  value: {{ .Values.global.environments.mongo.user | quote }}
- name: MONGO_PASS
  value: {{ .Values.global.environments.mongo.pass | quote }}
- name: MONGO_QUERY
  value: {{ .Values.global.environments.mongo.query | default "replicaSet=rs0&retryWrites=true&authSource=admin" | quote }}
# PostgreSQL
- name: POSTGRES_DB
  value: {{ .Values.global.environments.postgres.db | default "client" | quote }}
- name: POSTGRES_PREFIX
  value: {{ .Values.global.environments.postgres.prefix | default "hai" | quote }}
- name: POSTGRES_USER
  value: {{ .Values.global.environments.postgres.user | default "postgres" | quote }}
- name: POSTGRES_PASSWORD
  value: {{ .Values.global.environments.postgres.password | quote }}
- name: POSTGRES_PORT
  value: {{ .Values.global.environments.postgres.port | default "5432" | quote }}
- name: POSTGRES_HOST
  value: {{ .Values.global.environments.postgres.host | default "postgres-cluster-rw.cnpg-system.svc.cluster.local" | quote }}
- name: POSTGRES_POOL_MAX
  value: {{ .Values.global.environments.postgres.pool.max | default "5" | quote }}
- name: POSTGRES_IDLE_TIMEOUT
  value: {{ .Values.global.environments.postgres.pool.idleTimeoutMillis | default "30000" | quote }}
- name: POSTGRES_CONNECTION_TIMEOUT
  value: {{ .Values.global.environments.postgres.pool.connectionTimeoutMillis | default "10000" | quote }}
# **********************
# Broker Services
# **********************
# Nats
- name: NATS_USER
  value: {{ .Values.global.environments.nats.user | default "tenant30" | quote }}
- name: NATS_PASS
  value: {{ .Values.global.environments.nats.pass | default "tenant30" | quote }}
- name: NATS_TIMEOUT
  value: {{ .Values.global.environments.nats.timeout | default "90000" | quote }}
- name: NATS_SERVERS
  value: {{ .Values.global.environments.nats.servers | default "nats://localhost:4222" | quote }}
# *****************************
# OAuth Information
# *****************************
# Google
- name: GOOGLE_CLIENT_ID
  value: {{ .Values.global.environments.google.client.id | quote }}
- name: GOOGLE_CLIENT_SECRET
  value: {{ .Values.global.environments.google.client.secret | quote }}
- name: GOOGLE_REDIRECT_URI
  value: {{ .Values.global.environments.google.client.redirectUri | default "/oauth" | quote }}
# **********************
# Push Information
# **********************
# VAPID
- name: VAPID_PUBLIC_KEY
  value: {{ .Values.global.environments.vapid.publicKey | quote }}
- name: VAPID_PRIVATE_KEY
  value: {{ .Values.global.environments.vapid.privateKey | quote }}
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
  value: {{ .Values.global.environments.apm.serverUrl | quote }}
- name: ELASTIC_APM_SECRET_TOKEN
  value: {{ .Values.global.environments.apm.secretToken | quote }}
- name: ELASTIC_APM_VERIFY_SERVER_CERT
  value: {{ .Values.global.environments.apm.verifyServerCert | default "false" | quote }}
- name: MACHINE_ID
  value: {{ .Values.global.environments.machineId | quote }}
# **********************
# Wenex Coworkers
# **********************
- name: COWORKERS
  value: {{ join "," .Values.global.environments.coworkers | quote }}
{{- end }}
