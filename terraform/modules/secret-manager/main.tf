resource "random_password" "database" {
  length  = 32
  special = true
}

resource "google_secret_manager_secret" "database_password" {
  secret_id = "${var.name_prefix}-database-password"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "database_password" {
  secret      = google_secret_manager_secret.database_password.id
  secret_data = random_password.database.result
}
