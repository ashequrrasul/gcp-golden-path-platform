variable "repo_root" {
  description = "Absolute path to the deployment repository root."
  type        = string
}

variable "grafana_admin_user" {
  description = "Grafana admin user."
  type        = string
}

variable "grafana_admin_password" {
  description = "Grafana admin password."
  type        = string
  sensitive   = true
}

variable "install_logging" {
  description = "Install Loki and Promtail."
  type        = bool
  default     = true
}

variable "install_istio" {
  description = "Install Istio base, control plane, and ingress gateway."
  type        = bool
  default     = true
}
