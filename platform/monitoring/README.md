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
