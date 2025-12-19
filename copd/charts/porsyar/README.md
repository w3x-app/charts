# porsyar

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square)

A Helm chart for Porsyar with PostgreSQL, Redis

## Overview

This Helm chart deploys Porsyar, an enterprise-ready application with integrated PostgreSQL (with pgvector extension) and Redis support. The chart is production-ready with horizontal pod autoscaling, health checks, and comprehensive configuration options.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PersistentVolume provisioner support in the underlying infrastructure (for PostgreSQL and Redis persistence)

## Quick Start

### Basic Installation

```bash
# Add the repository (if using a Helm repository)
helm repo add charts https://your-charts-repo.com
helm repo update

# Install with default values
helm install porsyar charts/porsyar

# Install with custom values
helm install porsyar charts/porsyar -f custom-values.yaml
```

### Required Configuration

Before deploying to production, you must configure the following in your `values.yaml`:

1. **Domain/URLs**: Update `deployment.env.WEBAPP_URL` and `deployment.env.NEXTAUTH_URL` with your actual domain
2. **Secrets**: Generate and set secure values for `secret.NEXTAUTH_SECRET`, `secret.ENCRYPTION_KEY`, and `secret.CRON_SECRET`
3. **Image Registry**: Update `deployment.image.registry` and `deployment.image.repository` with your container registry

### Generating Secrets

```bash
# Generate secure random secrets
openssl rand -hex 32  # Use for NEXTAUTH_SECRET
openssl rand -hex 32  # Use for ENCRYPTION_KEY
openssl rand -hex 32  # Use for CRON_SECRET
```

## Configuration

The following table lists the main configurable parameters of the Porsyar chart and their default values.

### Application Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `deployment.image.registry` | Container registry | `registry.wenex.tech` |
| `deployment.image.repository` | Image repository | `porsyar-enterprise` |
| `deployment.image.tag` | Image tag | `v4` |
| `deployment.replicas` | Number of replicas | `1` |
| `deployment.env.WEBAPP_URL.value` | Base URL of your application | `https://porsyar.wenex.tech` |
| `deployment.env.NEXTAUTH_URL.value` | NextAuth URL (same as WEBAPP_URL) | `https://porsyar.wenex.tech` |
| `deployment.env.EMAIL_VERIFICATION_DISABLED.value` | Disable email verification | `"1"` |
| `deployment.env.PASSWORD_RESET_DISABLED.value` | Disable password reset | `"1"` |
| `deployment.env.TELEMETRY_DISABLED.value` | Disable telemetry | `"1"` |

### Email/SMTP Configuration (Optional)

To enable email functionality, uncomment and configure these in `values.yaml`:

| Parameter | Description | Example |
|-----------|-------------|---------|
| `deployment.env.MAIL_FROM.value` | Email sender address | `noreply@yourdomain.com` |
| `deployment.env.MAIL_FROM_NAME.value` | Sender name | `Porsyar` |
| `deployment.env.SMTP_HOST.value` | SMTP server hostname | `smtp.gmail.com` |
| `deployment.env.SMTP_PORT.value` | SMTP server port | `587` |
| `deployment.env.SMTP_USER.value` | SMTP username | `your_username` |
| `deployment.env.SMTP_PASSWORD.value` | SMTP password | `your_password` |
| `deployment.env.SMTP_SECURE_ENABLED.value` | Enable TLS (port 465) | `"0"` |
| `deployment.env.SMTP_AUTHENTICATED.value` | Require authentication | `"1"` |
| `deployment.env.SMTP_REJECT_UNAUTHORIZED_TLS.value` | Reject unauthorized TLS | `"1"` |

### S3 Storage Configuration (Optional)

For S3-compatible object storage:

| Parameter | Description | Example |
|-----------|-------------|---------|
| `deployment.env.S3_ACCESS_KEY.value` | S3 access key | `your-access-key` |
| `deployment.env.S3_SECRET_KEY.value` | S3 secret key | `your-secret-key` |
| `deployment.env.S3_REGION.value` | S3 region | `us-east-1` |
| `deployment.env.S3_BUCKET_NAME.value` | S3 bucket name | `your-bucket` |
| `deployment.env.S3_ENDPOINT_URL.value` | S3 endpoint (for compatible services) | `https://s3.example.com` |
| `deployment.env.S3_FORCE_PATH_STYLE.value` | Force path-style URLs | `"1"` |

### Resources (Production-Tuned)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `deployment.resources.limits.cpu` | CPU limit | `2` |
| `deployment.resources.limits.memory` | Memory limit | `4Gi` |
| `deployment.resources.requests.cpu` | CPU request | `1` |
| `deployment.resources.requests.memory` | Memory request | `2Gi` |

### Autoscaling (High Availability)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `autoscaling.enabled` | Enable HPA | `true` |
| `autoscaling.minReplicas` | Minimum replicas for HA | `2` |
| `autoscaling.maxReplicas` | Maximum replicas | `20` |
| `autoscaling.metrics[0].resource.target.averageUtilization` | CPU target | `60` |
| `autoscaling.metrics[1].resource.target.averageUtilization` | Memory target | `60` |

### Secrets

| Parameter | Description | Default |
|-----------|-------------|---------|
| `secret.enabled` | Enable secret creation | `true` |
| `secret.NEXTAUTH_SECRET` | NextAuth secret (32-byte hex) | Generated value |
| `secret.ENCRYPTION_KEY` | Encryption key (32-byte hex) | Generated value |
| `secret.CRON_SECRET` | Cron job secret (32-byte hex) | Generated value |

### PostgreSQL Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `postgresql.enabled` | Enable PostgreSQL | `true` |
| `postgresql.auth.username` | Database username | `porsyar` |
| `postgresql.auth.database` | Database name | `porsyar` |
| `postgresql.primary.persistence.size` | Storage size (critical: large for growth) | `100Gi` |
| `postgresql.primary.resources.limits.cpu` | CPU limit (high: DB bottleneck prevention) | `2` |
| `postgresql.primary.resources.limits.memory` | Memory limit (high: DB performance) | `4Gi` |
| `postgresql.primary.resources.requests.cpu` | CPU request | `1` |
| `postgresql.primary.resources.requests.memory` | Memory request | `2Gi` |

### Redis Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `redis.enabled` | Enable Redis | `true` |
| `redis.architecture` | Redis architecture | `standalone` |
| `redis.auth.enabled` | Enable authentication | `false` |
| `redis.master.persistence.enabled` | Enable persistence | `true` |
| `redis.master.persistence.size` | Storage size | `8Gi` |
| `redis.master.resources.limits.cpu` | CPU limit | `500m` |
| `redis.master.resources.limits.memory` | Memory limit | `1Gi` |
| `redis.master.resources.requests.cpu` | CPU request | `250m` |
| `redis.master.resources.requests.memory` | Memory request | `512Mi` |

### Ingress

| Parameter | Description | Default |
|-----------|-------------|---------|
| `ingress.enabled` | Enable Ingress | `false` |
| `ingress.ingressClassName` | Ingress class | `alb` |
| `ingress.hosts[0].host` | Hostname | `k8s.porsyar.com` |

### Service Monitor (Prometheus)

| Parameter | Description | Default |
|-----------|-------------|---------|
| `serviceMonitor.enabled` | Enable ServiceMonitor | `true` |
| `serviceMonitor.endpoints[0].interval` | Scrape interval | `5s` |
| `serviceMonitor.endpoints[0].path` | Metrics path | `/metrics` |

## Production Deployment Best Practices

1. **High Availability**: The chart defaults to 2 minimum replicas for HA
2. **Resource Limits**: Production-tuned resource limits are set to prevent resource exhaustion
3. **Persistence**: Both PostgreSQL and Redis use persistent volumes
4. **Health Checks**: Comprehensive liveness, readiness, and startup probes
5. **Security**: Read-only root filesystem, non-root user execution
6. **Monitoring**: Prometheus metrics endpoint exposed on port 9464

## External Dependencies

To use external PostgreSQL or Redis instead of the bundled ones:

```yaml
postgresql:
  enabled: false
  externalDatabaseUrl: "postgresql://user:pass@host:5432/dbname"

redis:
  enabled: false
  externalRedisUrl: "redis://host:6379"
```

## Upgrading

```bash
# Upgrade to a new version
helm upgrade porsyar charts/porsyar -f values.yaml

# Upgrade and reuse existing values
helm upgrade porsyar charts/porsyar --reuse-values
```

## Uninstalling

```bash
# Uninstall the release
helm uninstall porsyar

# Note: PersistentVolumeClaims are not deleted automatically
# To delete them:
kubectl delete pvc -l app.kubernetes.io/instance=porsyar
```

## Maintainers

| Name | Email | Url |
| ---- | ------ | --- |
| Porsyar | <info@phaicare.com> |  |

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| oci://registry-1.docker.io/bitnamicharts | postgresql | 16.4.16 |
| oci://registry-1.docker.io/bitnamicharts | redis | 20.11.2 |

---

## Complete Values Reference

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaling.additionalLabels | object | `{}` | Additional labels for HPA |
| autoscaling.annotations | object | `{}` | Annotations for HPA |
| autoscaling.enabled | bool | `true` | Enable horizontal pod autoscaling |
| autoscaling.maxReplicas | int | `20` | Maximum number of replicas (production) |
| autoscaling.metrics[0].resource.name | string | `"cpu"` | CPU metric for autoscaling |
| autoscaling.metrics[0].resource.target.averageUtilization | int | `60` | Target CPU utilization (%) |
| autoscaling.metrics[0].resource.target.type | string | `"Utilization"` | Metric target type |
| autoscaling.metrics[0].type | string | `"Resource"` | Metric type |
| autoscaling.metrics[1].resource.name | string | `"memory"` | Memory metric for autoscaling |
| autoscaling.metrics[1].resource.target.averageUtilization | int | `60` | Target memory utilization (%) |
| autoscaling.metrics[1].resource.target.type | string | `"Utilization"` | Metric target type |
| autoscaling.metrics[1].type | string | `"Resource"` | Metric type |
| autoscaling.minReplicas | int | `2` | Minimum number of replicas (HA) |
| componentOverride | string | `""` |  |
| cronJob.enabled | bool | `false` |  |
| cronJob.jobs | object | `{}` |  |
| deployment.additionalLabels | object | `{}` |  |
| deployment.additionalPodAnnotations | object | `{}` |  |
| deployment.additionalPodLabels | object | `{}` |  |
| deployment.affinity | object | `{}` |  |
| deployment.annotations | object | `{}` |  |
| deployment.args | list | `[]` |  |
| deployment.command | list | `[]` |  |
| deployment.containerSecurityContext.readOnlyRootFilesystem | bool | `true` |  |
| deployment.containerSecurityContext.runAsNonRoot | bool | `true` |  |
| deployment.env.EMAIL_VERIFICATION_DISABLED.value | string | `"1"` | Disable email verification |
| deployment.env.NEXTAUTH_URL.value | string | `"https://porsyar.wenex.tech"` | NextAuth URL (must match WEBAPP_URL) |
| deployment.env.PASSWORD_RESET_DISABLED.value | string | `"1"` | Disable password reset |
| deployment.env.TELEMETRY_DISABLED.value | string | `"1"` | Disable telemetry data collection |
| deployment.env.WEBAPP_URL.value | string | `"https://porsyar.wenex.tech"` | Base URL of the application |
| deployment.envFrom | string | `nil` |  |
| deployment.image.digest | string | `""` |  |
| deployment.image.pullPolicy | string | `"IfNotPresent"` |  |
| deployment.image.registry | string | `"registry.wenex.tech"` | Container registry |
| deployment.image.repository | string | `"porsyar-enterprise"` | Image repository name |
| deployment.image.tag | string | `"v4"` | Image tag |
| deployment.imagePullSecrets | string | `""` |  |
| deployment.nodeSelector | object | `{}` |  |
| deployment.ports.http.containerPort | int | `3000` |  |
| deployment.ports.http.exposed | bool | `true` |  |
| deployment.ports.http.protocol | string | `"TCP"` |  |
| deployment.ports.metrics.containerPort | int | `9464` |  |
| deployment.ports.metrics.exposed | bool | `true` |  |
| deployment.ports.metrics.protocol | string | `"TCP"` |  |
| deployment.probes.livenessProbe.failureThreshold | int | `5` |  |
| deployment.probes.livenessProbe.httpGet.path | string | `"/health"` |  |
| deployment.probes.livenessProbe.httpGet.port | int | `3000` |  |
| deployment.probes.livenessProbe.initialDelaySeconds | int | `10` |  |
| deployment.probes.livenessProbe.periodSeconds | int | `10` |  |
| deployment.probes.livenessProbe.successThreshold | int | `1` |  |
| deployment.probes.livenessProbe.timeoutSeconds | int | `5` |  |
| deployment.probes.readinessProbe.failureThreshold | int | `5` |  |
| deployment.probes.readinessProbe.httpGet.path | string | `"/health"` |  |
| deployment.probes.readinessProbe.httpGet.port | int | `3000` |  |
| deployment.probes.readinessProbe.initialDelaySeconds | int | `10` |  |
| deployment.probes.readinessProbe.periodSeconds | int | `10` |  |
| deployment.probes.readinessProbe.successThreshold | int | `1` |  |
| deployment.probes.readinessProbe.timeoutSeconds | int | `5` |  |
| deployment.probes.startupProbe.failureThreshold | int | `30` |  |
| deployment.probes.startupProbe.periodSeconds | int | `10` |  |
| deployment.probes.startupProbe.tcpSocket.port | int | `3000` |  |
| deployment.reloadOnChange | bool | `false` |  |
| deployment.replicas | int | `1` |  |
| deployment.resources.limits.cpu | string | `"2"` | CPU limit (production-tuned) |
| deployment.resources.limits.memory | string | `"4Gi"` | Memory limit (production-tuned) |
| deployment.resources.requests.cpu | string | `"1"` | CPU request |
| deployment.resources.requests.memory | string | `"2Gi"` | Memory request (production-tuned) |
| deployment.revisionHistoryLimit | int | `2` |  |
| deployment.securityContext | object | `{}` |  |
| deployment.strategy.type | string | `"RollingUpdate"` |  |
| deployment.tolerations | list | `[]` |  |
| deployment.topologySpreadConstraints | list | `[]` |  |
| enterprise.enabled | bool | `false` |  |
| enterprise.licenseKey | string | `""` |  |
| externalSecret.enabled | bool | `false` |  |
| externalSecret.files | object | `{}` |  |
| externalSecret.refreshInterval | string | `"1h"` |  |
| externalSecret.secretStore.kind | string | `"ClusterSecretStore"` |  |
| externalSecret.secretStore.name | string | `"aws-secrets-manager"` |  |
| ingress.annotations | object | `{}` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"k8s.porsyar.com"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"Prefix"` |  |
| ingress.hosts[0].paths[0].serviceName | string | `"porsyar"` |  |
| ingress.ingressClassName | string | `"alb"` |  |
| nameOverride | string | `""` |  |
| partOfOverride | string | `""` |  |
| postgresql.auth.database | string | `"porsyar"` |  |
| postgresql.auth.existingSecret | string | `"porsyar-app-secrets"` |  |
| postgresql.auth.secretKeys.adminPasswordKey | string | `"POSTGRES_ADMIN_PASSWORD"` |  |
| postgresql.auth.secretKeys.userPasswordKey | string | `"POSTGRES_USER_PASSWORD"` |  |
| postgresql.auth.username | string | `"porsyar"` |  |
| postgresql.enabled | bool | `true` |  |
| postgresql.externalDatabaseUrl | string | `""` |  |
| postgresql.fullnameOverride | string | `"porsyar-postgresql"` |  |
| postgresql.global.security.allowInsecureImages | bool | `true` |  |
| postgresql.image.repository | string | `"pgvector/pgvector"` |  |
| postgresql.image.tag | string | `"0.8.0-pg17"` |  |
| postgresql.primary.containerSecurityContext.enabled | bool | `true` |  |
| postgresql.primary.containerSecurityContext.readOnlyRootFilesystem | bool | `false` |  |
| postgresql.primary.containerSecurityContext.runAsUser | int | `1001` |  |
| postgresql.primary.networkPolicy.enabled | bool | `false` |  |
| postgresql.primary.persistence.enabled | bool | `true` |  |
| postgresql.primary.persistence.size | string | `"100Gi"` | PostgreSQL storage size (critical: large for growth) |
| postgresql.primary.resources.limits.cpu | string | `"2"` | PostgreSQL CPU limit (high: prevent bottleneck) |
| postgresql.primary.resources.limits.memory | string | `"4Gi"` | PostgreSQL memory limit (high: DB performance) |
| postgresql.primary.resources.requests.cpu | string | `"1"` | PostgreSQL CPU request |
| postgresql.primary.resources.requests.memory | string | `"2Gi"` | PostgreSQL memory request |
| postgresql.primary.podSecurityContext.enabled | bool | `true` |  |
| postgresql.primary.podSecurityContext.fsGroup | int | `1001` |  |
| postgresql.primary.podSecurityContext.runAsUser | int | `1001` |  |
| rbac.enabled | bool | `false` |  |
| rbac.serviceAccount.additionalLabels | object | `{}` |  |
| rbac.serviceAccount.annotations | object | `{}` |  |
| rbac.serviceAccount.enabled | bool | `false` |  |
| rbac.serviceAccount.name | string | `""` |  |
| redis.architecture | string | `"standalone"` | Redis architecture (standalone/replication) |
| redis.auth.enabled | bool | `false` | Enable Redis authentication |
| redis.auth.existingSecret | string | `"porsyar-app-secrets"` | Existing secret for Redis password |
| redis.auth.existingSecretPasswordKey | string | `"REDIS_PASSWORD"` | Key in secret for password |
| redis.enabled | bool | `true` | Enable Redis deployment |
| redis.externalRedisUrl | string | `""` | External Redis URL (if not using bundled Redis) |
| redis.fullnameOverride | string | `"porsyar-redis"` | Redis service name override |
| redis.master.persistence.enabled | bool | `true` | Enable Redis persistence |
| redis.master.persistence.size | string | `"8Gi"` | Redis storage size (production) |
| redis.master.resources.limits.cpu | string | `"500m"` | Redis CPU limit |
| redis.master.resources.limits.memory | string | `"1Gi"` | Redis memory limit |
| redis.master.resources.requests.cpu | string | `"250m"` | Redis CPU request |
| redis.master.resources.requests.memory | string | `"512Mi"` | Redis memory request |
| redis.networkPolicy.enabled | bool | `false` | Enable network policy |
| secret.enabled | bool | `true` | Enable automatic secret creation |
| secret.NEXTAUTH_SECRET | string | Generated | NextAuth secret (32-byte hex) |
| secret.ENCRYPTION_KEY | string | Generated | Application encryption key (32-byte hex) |
| secret.CRON_SECRET | string | Generated | Cron job authentication secret (32-byte hex) |
| service.additionalLabels | object | `{}` |  |
| service.annotations | object | `{}` |  |
| service.enabled | bool | `true` |  |
| service.ports | list | `[]` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceMonitor.additionalLabels | string | `nil` |  |
| serviceMonitor.annotations | string | `nil` |  |
| serviceMonitor.enabled | bool | `true` |  |
| serviceMonitor.endpoints[0].interval | string | `"5s"` |  |
| serviceMonitor.endpoints[0].path | string | `"/metrics"` |  |
| serviceMonitor.endpoints[0].port | string | `"metrics"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
