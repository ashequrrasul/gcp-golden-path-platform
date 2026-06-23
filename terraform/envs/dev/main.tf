locals {
  name_prefix = "golden-path-${var.environment}"
}

module "network" {
  source      = "../../modules/network"
  project_id  = var.project_id
  region      = var.region
  name_prefix = local.name_prefix
}

module "artifact_registry" {
  source      = "../../modules/artifact-registry"
  project_id  = var.project_id
  region      = var.region
  name_prefix = "golden-path"
}

module "iam" {
  source              = "../../modules/iam"
  project_id          = var.project_id
  github_repository   = var.github_repository
  github_repositories = var.github_repositories
  namespace           = "golden-path"
  ksa_name            = "product-service"
}

module "secret_manager" {
  source      = "../../modules/secret-manager"
  project_id  = var.project_id
  name_prefix = local.name_prefix
}

module "cloud_sql" {
  count = var.enable_cloud_sql ? 1 : 0

  source          = "../../modules/cloud-sql"
  project_id      = var.project_id
  region          = var.region
  name_prefix     = local.name_prefix
  network_id      = module.network.network_id
  database_secret = module.secret_manager.database_password_secret_id

  depends_on = [module.network]
}

module "gke" {
  source                        = "../../modules/gke"
  project_id                    = var.project_id
  location                      = var.gke_location
  name_prefix                   = local.name_prefix
  network_self_link             = module.network.network_self_link
  subnet_self_link              = module.network.subnet_self_link
  pods_range_name               = module.network.pods_range_name
  services_range_name           = module.network.services_range_name
  node_service_account_email    = module.iam.gke_node_service_account_email
  machine_type                  = "e2-standard-2"
  disk_type                     = "pd-balanced"
  disk_size_gb                  = 30
  min_node_count                = 1
  max_node_count                = 4
  master_authorized_cidr_blocks = var.master_authorized_cidr_blocks
  deletion_protection           = var.gke_deletion_protection
}

module "platform_addons" {
  count = var.enable_platform_addons ? 1 : 0

  source                 = "../../modules/platform-addons"
  repo_root              = abspath("${path.module}/../../..")
  grafana_admin_user     = var.grafana_admin_user
  grafana_admin_password = var.grafana_admin_password
  install_logging        = var.install_logging
  install_istio          = var.install_istio

  depends_on = [
    module.gke,
    module.cloud_sql,
  ]
}
