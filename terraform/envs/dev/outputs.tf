output "cluster_name" {
  value = module.gke.cluster_name
}

output "artifact_registry_repository" {
  value = module.artifact_registry.repository_id
}

output "cloud_sql_connection_name" {
  value = var.enable_cloud_sql ? module.cloud_sql[0].connection_name : null
}

output "workload_identity_service_account" {
  value = module.iam.workload_identity_service_account_email
}

output "github_deployer_service_account" {
  value = module.iam.github_deployer_service_account_email
}

output "github_workload_identity_provider" {
  value = module.iam.github_workload_identity_provider
}
