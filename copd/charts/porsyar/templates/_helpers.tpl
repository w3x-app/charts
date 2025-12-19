{{/*
Expand the name of the chart.
This function ensures that the chart name is either taken from `nameOverride` or defaults to `.Chart.Name`.
It also truncates the name to a maximum of 63 characters and removes trailing hyphens.
*/}}
{{- define "porsyar.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Define the application version to be used in labels.
The version is taken from `.Values.deployment.image.tag` if provided, otherwise it defaults to `.Chart.Version`.
It ensures the version only contains alphanumeric characters, underscores, dots, or hyphens, replacing any invalid characters with a hyphen.
*/}}
{{- define "porsyar.version" -}}
  {{- $appVersion := default .Chart.Version .Values.deployment.image.tag -}}
  {{- regexReplaceAll "[^a-zA-Z0-9_\\.\\-]" $appVersion "-" | trunc 63 | trimSuffix "-" -}}
{{- end }}


{{/*
Generate a chart name and version string to be used in Helm chart labels.
This follows the format: `<ChartName>-<ChartVersion>`, replacing `+` with `_` and truncating to 63 characters.
*/}}
{{- define "porsyar.chart" -}}
  {{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}


{{/*
Common labels applied to Kubernetes resources.
These labels help identify and manage the application.
*/}}
{{- define "porsyar.labels" -}}
helm.sh/chart: {{ include "porsyar.chart" . }}

# Selector labels
{{ include "porsyar.selectorLabels" . }}

# Application version label
{{- with include "porsyar.version" . }}
app.kubernetes.io/version: {{ . | quote }}
{{- end }}

# Managed by Helm
app.kubernetes.io/managed-by: {{ .Release.Service }}

# Part of label, defaults to the chart name if `partOfOverride` is not provided.
app.kubernetes.io/part-of: {{ .Values.partOfOverride | default (include "porsyar.name" .) }}
{{- end }}


{{/*
Selector labels used for identifying workloads in Kubernetes.
These labels ensure that selectors correctly map to the deployed resources.
*/}}
{{- define "porsyar.selectorLabels" -}}
app.kubernetes.io/name: {{ include "porsyar.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/component: {{ .Values.componentOverride | default (include "porsyar.name" .) }}
{{- end }}


{{/*
Renders a value that contains a Helm template.
Usage:
{{ include "porsyar.tplvalues.render" ( dict "value" .Values.path.to.the.Value "context" $) }}
This function allows rendering values dynamically.
*/}}
{{- define "porsyar.tplvalues.render" -}}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context }}
    {{- else }}
        {{- tpl (.value | toYaml) .context }}
    {{- end }}
{{- end }}


{{/*
Allow the release namespace to be overridden.
If `namespaceOverride` is provided, it will be used; otherwise, it defaults to `.Release.Namespace`.
*/}}
{{- define "porsyar.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride -}}
{{- end -}}


{{- define "porsyar.postgresAdminPassword" -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-app-secrets" (include "porsyar.name" .))) }}
{{- if and $secret (index $secret.data "POSTGRES_ADMIN_PASSWORD") }}
    {{- index $secret.data "POSTGRES_ADMIN_PASSWORD" | b64dec -}}
{{- else }}
    {{- randAlphaNum 16 -}}
{{- end -}}
{{- end }}

{{- define "porsyar.postgresUserPassword" -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-app-secrets" (include "porsyar.name" .))) }}
{{- if and $secret (index $secret.data "POSTGRES_USER_PASSWORD") }}
    {{- index $secret.data "POSTGRES_USER_PASSWORD" | b64dec -}}
{{- else }}
    {{- randAlphaNum 16 -}}
{{- end -}}
{{- end }}

{{- define "porsyar.redisPassword" -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-app-secrets" (include "porsyar.name" .))) }}
{{- if and $secret (index $secret.data "REDIS_PASSWORD") }}
    {{- index $secret.data "REDIS_PASSWORD" | b64dec -}}
{{- else }}
    {{- randAlphaNum 16 -}}
{{- end -}}
{{- end }}

{{- define "porsyar.cronSecret" -}}
{{- if and .Values.secret .Values.secret.CRON_SECRET (ne .Values.secret.CRON_SECRET "") }}
    {{- .Values.secret.CRON_SECRET -}}
{{- else }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-app-secrets" (include "porsyar.name" .))) }}
    {{- if and $secret (index $secret.data "CRON_SECRET") }}
        {{- index $secret.data "CRON_SECRET" | b64dec -}}
    {{- else }}
        {{- randAlphaNum 32 -}}
    {{- end -}}
{{- end -}}
{{- end }}

{{- define "porsyar.encryptionKey" -}}
{{- if and .Values.secret .Values.secret.ENCRYPTION_KEY (ne .Values.secret.ENCRYPTION_KEY "") }}
    {{- .Values.secret.ENCRYPTION_KEY -}}
{{- else }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-app-secrets" (include "porsyar.name" .))) }}
    {{- if and $secret (index $secret.data "ENCRYPTION_KEY") }}
        {{- index $secret.data "ENCRYPTION_KEY" | b64dec -}}
    {{- else }}
        {{- randAlphaNum 32 -}}
    {{- end -}}
{{- end -}}
{{- end }}

{{- define "porsyar.nextAuthSecret" -}}
{{- if and .Values.secret .Values.secret.NEXTAUTH_SECRET (ne .Values.secret.NEXTAUTH_SECRET "") }}
    {{- .Values.secret.NEXTAUTH_SECRET -}}
{{- else }}
    {{- $secret := (lookup "v1" "Secret" .Release.Namespace (printf "%s-app-secrets" (include "porsyar.name" .))) }}
    {{- if and $secret (index $secret.data "NEXTAUTH_SECRET") }}
        {{- index $secret.data "NEXTAUTH_SECRET" | b64dec -}}
    {{- else }}
        {{- randAlphaNum 32 -}}
    {{- end -}}
{{- end -}}
{{- end }}
