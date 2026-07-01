terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.33"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.15"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14"
    }
  }
}

data "google_client_config" "default" {}

locals {
  kubernetes_host                   = module.gke.endpoint != null ? "https://${module.gke.endpoint}" : "https://127.0.0.1"
  kubernetes_cluster_ca_certificate = module.gke.cluster_ca_certificate != "" ? base64decode(module.gke.cluster_ca_certificate) : null
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

provider "kubernetes" {
  host                   = local.kubernetes_host
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = local.kubernetes_cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = local.kubernetes_host
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = local.kubernetes_cluster_ca_certificate
  }
}

provider "kubectl" {
  host                   = local.kubernetes_host
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = local.kubernetes_cluster_ca_certificate
  load_config_file       = false
}
