resource "google_artifact_registry_repository" "docker" {
  location      = var.region
  repository_id = var.name_prefix
  description   = "Docker images for the Golden Path platform"
  format        = "DOCKER"

  docker_config {
    immutable_tags = true
  }
}
