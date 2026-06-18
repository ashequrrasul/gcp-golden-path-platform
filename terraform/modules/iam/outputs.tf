output "gke_node_service_account_email" { value = google_service_account.gke_nodes.email }
output "workload_identity_service_account_email" { value = google_service_account.workload.email }
output "github_deployer_service_account_email" { value = google_service_account.github_deployer.email }
output "github_workload_identity_provider" { value = google_iam_workload_identity_pool_provider.github.name }
