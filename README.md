## Getting Started

1. Clone the repository.
2. Place your Helm charts in the designated directory.
3. Update the Helm repository index using:

```sh
# Lint charts
helm lint copd
helm lint phc
helm lint rsch

# Test template rendering
helm template copd
helm template phc
helm template rsch

# Package charts
helm package copd
helm package phc
helm package rsch

# Update repository index
helm repo index .
```

## Charts

### COPD
The COPD chart includes the following subcharts:
- **services**: Backend services
- **workers**: Background workers
- **assets**: Asset management
- **frontend**: Frontend application
- **porsyar**: Survey platform (with PostgreSQL and Redis)

To enable porsyar:
```sh
helm install my-copd copd --set porsyar.enabled=true
```

### PHC
Primary Healthcare chart.

### RSCH
Research chart.
