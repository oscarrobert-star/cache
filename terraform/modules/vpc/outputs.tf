output "network_self_link" {
  description = "Self link of the VPC network"
  value       = google_compute_network.main.self_link
}

output "serverless_connector_id" {
  description = "serverless connector id"
  value       = google_vpc_access_connector.serverless_connector.id
}

# output "network_name" {
#   description = "Network name"
#   value       = google_compute_network.main.id
# }

# output "subnet_name" {
#   description = "subnet_name"
#   value       = google_compute_subnetwork.main.id
# }