# Monitoring Setup

This installs kube-prometheus-stack with Prometheus and Grafana sized for the current one-node dev cluster.

## Install

```bash
kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

kubectl -n monitoring create secret generic grafana-admin \
  --from-literal=admin-user=admin \
  --from-literal=admin-password='REPLACE_WITH_STRONG_PASSWORD' \
  --dry-run=client -o yaml | kubectl apply -f -

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  -f platform/monitoring/kube-prometheus-stack-values.yaml
```

## Access Grafana

```bash
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
```

Open:

```text
http://localhost:3000
```

The app chart creates a `ServiceMonitor` that scrapes `/metrics`.

## E-commerce Dashboard and Alerts

Install the dashboard and Prometheus alert rules:

```bash
kubectl apply -f platform/monitoring/ecommerce-dashboard.yaml
kubectl apply -f platform/monitoring/ecommerce-prometheus-rules.yaml
kubectl apply -f platform/monitoring/istio-sidecar-podmonitor.yaml
```

If Grafana is already running, restart it so the sidecar picks up datasource UID changes:

```bash
kubectl -n monitoring rollout restart deploy/kube-prometheus-stack-grafana
```

Open Grafana and look for:

```text
Golden Path Ecommerce Overview
```

Check alert rules:

```bash
kubectl -n monitoring get prometheusrule ecommerce-observability-rules
```

Check Istio metrics:

```bash
kubectl -n monitoring get podmonitor istio-sidecars
```

Then query Prometheus:

```promql
sum by (source_workload, destination_workload) (rate(istio_requests_total{destination_workload_namespace="golden-path"}[5m]))
```

Alertmanager is disabled in the dev values, so alerts are visible in Prometheus/Grafana but are not routed to email, Slack, or PagerDuty yet.
