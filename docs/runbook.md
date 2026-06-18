# Operations Runbook

## Roll Back a Deployment

```bash
argocd app rollback golden-path-microservice
```

Or revert the Helm image tag commit and allow ArgoCD to sync.

## Rotate Database Password

1. Add a new Secret Manager version.
2. Wait for External Secrets Operator refresh or force sync:

```bash
kubectl -n golden-path annotate externalsecret golden-path-db force-sync=$(date +%s) --overwrite
```

3. Restart pods if the application only reads secrets on startup:

```bash
kubectl -n golden-path rollout restart deploy/golden-path-microservice
```

## Investigate Elevated Error Rates

1. Check Grafana service dashboard.
2. Inspect recent deployment in ArgoCD.
3. Query logs in Loki by namespace and app labels.
4. Review Kubernetes events:

```bash
kubectl -n golden-path get events --sort-by=.lastTimestamp
```
