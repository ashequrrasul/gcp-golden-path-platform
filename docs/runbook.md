# Operations Runbook

## Roll Back a Deployment

```bash
argocd app rollback product-service
```

Or revert the Helm image tag commit and allow ArgoCD to sync.

## Rotate Database Password

1. Add a new Secret Manager version.
2. Wait for External Secrets Operator refresh or force sync:

```bash
kubectl -n golden-path annotate externalsecret product-db force-sync=$(date +%s) --overwrite
```

3. Restart pods if the application only reads secrets on startup:

```bash
kubectl -n golden-path rollout restart deploy/product-service
```

## Investigate Elevated Error Rates

1. Check Grafana service dashboard.
2. Inspect recent deployment in ArgoCD.
3. Query logs in Loki by namespace and app labels.
4. Review Kubernetes events:

```bash
kubectl -n golden-path get events --sort-by=.lastTimestamp
```

## Verify Managed TLS

The shared ecommerce ingress uses a GKE `ManagedCertificate` for `gcp.lovelu.com`.

Check certificate provisioning:

```bash
kubectl -n golden-path describe managedcertificate ecommerce-managed-cert
```

Expected status after Google provisions the certificate:

```text
CertificateStatus: Active
DomainStatus:
  gcp.lovelu.com: Active
```

Check the ingress annotations and load balancer IP:

```bash
kubectl -n golden-path describe ingress ecommerce
```

Confirm DNS points to the reserved global IP:

```bash
gcloud compute addresses describe golden-path-ip --global --format="value(address)"
```

Then test HTTPS:

```bash
curl -I https://gcp.lovelu.com
curl -I http://gcp.lovelu.com
```

The HTTP request should redirect to HTTPS after the `FrontendConfig` is active. Managed certificates can take 15-60 minutes to become active.
