variable "project_id" {
  description = "Google Cloud project ID."
  type        = string
}

variable "region" {
  description = "Google Cloud region."
  type        = string
  default     = "us-central1"
}

variable "gke_location" {
  description = "GKE cluster location. Use a zone for one-node dev clusters, or a region for regional production clusters."
  type        = string
  default     = "us-central1-a"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "dev"
}

variable "github_repository" {
  description = "GitHub repository in owner/name format for deployer identity."
  type        = string
  default     = "ashequrrasul/gcp-golden-path-app"
}

variable "github_repositories" {
  description = "GitHub repositories in owner/name format allowed to use GCP Workload Identity Federation."
  type        = list(string)
  default = [
    "ashequrrasul/gcp-golden-path-app",
    "ashequrrasul/ecommerce-frontend"
  ]
}

variable "enable_cloud_sql" {
  description = "Create Cloud SQL PostgreSQL. Disable for free-tier/dev-cost mode."
  type        = bool
  default     = false
}

variable "master_authorized_cidr_blocks" {
  description = "CIDR blocks allowed to reach the GKE public control-plane endpoint."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "gke_deletion_protection" {
  description = "Protect the GKE cluster from Terraform destroy. Disable only for disposable dev clusters."
  type        = bool
  default     = false
}
