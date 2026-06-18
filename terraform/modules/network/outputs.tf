output "network_id" { value = google_compute_network.this.id }
output "network_self_link" { value = google_compute_network.this.self_link }
output "subnet_self_link" { value = google_compute_subnetwork.this.self_link }
output "pods_range_name" { value = google_compute_subnetwork.this.secondary_ip_range[0].range_name }
output "services_range_name" { value = google_compute_subnetwork.this.secondary_ip_range[1].range_name }
output "private_service_connection" { value = google_service_networking_connection.private_vpc_connection.id }
