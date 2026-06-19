variable "project_id" { type = string }
variable "github_repository" { type = string }
variable "github_repositories" {
  type    = list(string)
  default = []
}
variable "namespace" { type = string }
variable "ksa_name" { type = string }
