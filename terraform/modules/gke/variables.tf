variable "project_id" { type = string }
variable "location" { type = string }
variable "name_prefix" { type = string }
variable "network_self_link" { type = string }
variable "subnet_self_link" { type = string }
variable "pods_range_name" { type = string }
variable "services_range_name" { type = string }
variable "node_service_account_email" { type = string }

variable "machine_type" {
  description = "GKE node machine type."
  type        = string
  default     = "e2-standard-4"
}

variable "disk_type" {
  description = "GKE node boot disk type."
  type        = string
  default     = "pd-balanced"
}

variable "disk_size_gb" {
  description = "GKE node boot disk size in GB."
  type        = number
  default     = 30
}

variable "min_node_count" {
  description = "Minimum node count for the primary node pool."
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum node count for the primary node pool."
  type        = number
  default     = 4
}

variable "master_authorized_cidr_blocks" {
  description = "CIDR blocks allowed to reach the GKE public control-plane endpoint."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "deletion_protection" {
  description = "Protect the GKE cluster from Terraform destroy."
  type        = bool
  default     = true
}
