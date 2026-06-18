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
  source            = "../../modules/iam"
  project_id        = var.project_id
  github_repository = var.github_repository
  namespace         = "golden-path"
  ksa_name          = "golden-path-microservice"
}

module "secret_manager" {
  source      = "../../modules/secret-manager"
  project_id  = var.project_id
  name_prefix = local.name_prefix
}

module "cloud_sql" {
  source          = "../../modules/cloud-sql"
  project_id      = var.project_id
  region          = var.region
  name_prefix     = local.name_prefix
  network_id      = module.network.network_id
  database_secret = module.secret_manager.database_password_secret_id

  depends_on = [module.network]
}

module "gke" {
  source                     = "../../modules/gke"
  project_id                 = var.project_id
  region                     = var.region
  name_prefix                = local.name_prefix
  network_self_link          = module.network.network_self_link
  subnet_self_link           = module.network.subnet_self_link
  pods_range_name            = module.network.pods_range_name
  services_range_name        = module.network.services_range_name
  node_service_account_email = module.iam.gke_node_service_account_email
}
