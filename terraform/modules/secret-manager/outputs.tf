output "database_password_secret_id" { value = google_secret_manager_secret.database_password.id }
output "database_password_secret_name" { value = google_secret_manager_secret.database_password.secret_id }
