# gcp-golden-path-deploy

Deployment and platform repository for the GCP Golden Path.

This repo owns:

- Terraform infrastructure
- Private GKE cluster
- Artifact Registry
- Cloud SQL PostgreSQL
- Secret Manager
- IAM and Workload Identity
- Helm chart and environment values
- ArgoCD Application manifest
- Prometheus and Grafana values
- Loki setup notes
- Operational runbook

The application source code lives in:

```text
gcp-golden-path-app
```

## Where Terraform Should Stay

Terraform should stay in this deployment repo:

```text
terraform/
```

Reason: Terraform manages shared cloud infrastructure and environment state. Keeping it separate from application code gives you cleaner access control, safer production changes, better audit history, and a clearer GitOps boundary.

Recommended ownership:

```text
gcp-golden-path-app      app developers
gcp-golden-path-deploy   platform/devops owners
```

## First Deployment Steps

1. Create both GitHub repositories:

   ```text
   ashequrrasul/gcp-golden-path-app
   ashequrrasul/gcp-golden-path-deploy
   ```

2. In this repo, replace placeholders:

   - `YOUR_PROJECT_ID`
   - `ashequrrasul/gcp-golden-path-deploy`, if your GitHub owner or repo name differs
   - `ashequrrasul/gcp-golden-path-app`, if your GitHub owner or repo name differs
   - `gcp.lovelu.com`, if using that DNS name

3. Provision GCP infrastructure:

   ```bash
   cd terraform/envs/dev
   terraform init
   terraform apply \
     -var="project_id=YOUR_PROJECT_ID" \
     -var="github_repository=ashequrrasul/gcp-golden-path-app"
   ```

4. Configure the app repo GitHub secrets from Terraform outputs:

   ```bash
   terraform output github_workload_identity_provider
   terraform output github_deployer_service_account
   ```

5. Install cluster platform dependencies:

   ```bash
   gcloud container clusters get-credentials golden-path-dev \
     --region us-central1 \
     --project YOUR_PROJECT_ID

   kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -
   kubectl -n monitoring create secret generic grafana-admin \
     --from-literal=admin-user=admin \
     --from-literal=admin-password='REPLACE_WITH_STRONG_PASSWORD'

   helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
   helm repo add external-secrets https://charts.external-secrets.io
   helm repo update

   helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
     --namespace monitoring --create-namespace \
     -f platform/monitoring/kube-prometheus-stack-values.yaml

   helm upgrade --install external-secrets external-secrets/external-secrets \
     --namespace external-secrets --create-namespace \
     --set installCRDs=true
   ```

6. Install ArgoCD if needed, then apply:

   ```bash
   kubectl apply -f argocd/application.yaml
   ```

7. Push to `gcp-golden-path-app/main`. CI will build the image and update this deployment repo.
