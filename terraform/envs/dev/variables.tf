variable "project_id" {
  description = "Google Cloud project ID."
  type        = string
}

variable "region" {
  description = "Google Cloud region."
  type        = string
  default     = "us-central1"
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
