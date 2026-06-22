# Istio Service Mesh

This folder adds Istio as an optional mesh layer for the `golden-path` namespace.

The first implementation keeps the existing GCE Ingress, Google Managed Certificate, and static IP. Istio is used for in-cluster sidecars, telemetry, and service-to-service mTLS. This avoids changing DNS or replacing the working GCP load balancer.

## Install Istio

Install Istio with the default profile:

```bash
istioctl install --set profile=default -y
```

Verify Istio:

```bash
kubectl get pods -n istio-system
```

## Enable Injection and Mesh Policies

Apply the namespace label and mesh resources:

```bash
kubectl apply -f platform/istio/golden-path-namespace-label.yaml
kubectl apply -f platform/istio/peer-authentication.yaml
kubectl apply -f platform/istio/destination-rules.yaml
kubectl apply -f platform/istio/telemetry.yaml
```

Restart workloads so pods receive sidecars:

```bash
kubectl -n golden-path rollout restart deploy/ecommerce-frontend
kubectl -n golden-path rollout restart deploy/golden-path-microservice
kubectl -n golden-path rollout restart deploy/cart-payment-service
kubectl -n golden-path rollout restart deploy/order-service
```

Check sidecar injection:

```bash
kubectl -n golden-path get pods
kubectl -n golden-path get pod -l app.kubernetes.io/name=order-service -o jsonpath="{.items[0].spec.containers[*].name}"
```

Expected containers include:

```text
app istio-proxy
```

## Validate Mesh Traffic

Check Istio proxy status:

```bash
istioctl proxy-status
```

Generate traffic:

```bash
curl -I https://gcp.lovelu.com
curl https://gcp.lovelu.com/products
```

Then check Prometheus or Grafana for Istio metrics such as:

```promql
sum by (destination_service) (rate(istio_requests_total{destination_workload_namespace="golden-path"}[5m]))
```

## mTLS Mode

The first rollout uses:

```text
PERMISSIVE
```

Why: the current external GCE Ingress and Google health checks do not speak Istio mTLS. `PERMISSIVE` lets both plain HTTP and mesh mTLS work while you verify sidecars and telemetry.

After moving external traffic to an Istio ingress gateway, you can change `PeerAuthentication` to:

```yaml
mtls:
  mode: STRICT
```

## Resource Note

Istio sidecars add CPU and memory overhead to every pod. On the current dev cluster, keep at least one `e2-standard-2` node running, and expect autoscaling to add nodes when monitoring, logging, and all app sidecars are active.
