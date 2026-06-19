data "google_secret_manager_secret_version" "database_password" {
  secret = var.database_secret
}

resource "google_sql_database_instance" "postgres" {
  name             = "${var.name_prefix}-postgres"
  region           = var.region
  database_version = "POSTGRES_16"

  settings {
    edition           = "ENTERPRISE"
    tier              = "db-custom-1-3840"
    availability_type = "ZONAL"
    disk_type         = "PD_SSD"
    disk_size         = 20
    disk_autoresize   = true

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.network_id
    }
  }

  deletion_protection = true
}

resource "google_sql_database" "app" {
  name     = "app"
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "app" {
  name     = "app"
  instance = google_sql_database_instance.postgres.name
  password = data.google_secret_manager_secret_version.database_password.secret_data
}
