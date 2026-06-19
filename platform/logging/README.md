# Loki Logging Setup

This template installs a lightweight Loki and Promtail setup for the dev GKE cluster.

Recommended install:

```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
helm upgrade --install loki grafana/loki \
  --namespace logging --create-namespace \
  -f platform/logging/loki-values.yaml

helm upgrade --install promtail grafana/promtail \
  --namespace logging \
  -f platform/logging/promtail-values.yaml
```

Production notes:

- Use GCS object storage for Loki chunks and ruler data.
- Set retention to match compliance requirements.
- Restrict Grafana data source permissions by team.
- Use Workload Identity for Loki storage access.
- Keep application logs structured JSON where possible.
