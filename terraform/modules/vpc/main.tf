resource "google_compute_network" "main" {
  name                    = var.network_name
  auto_create_subnetworks = false
  project                 = var.project
}

resource "google_compute_subnetwork" "main" {
  name          = "${var.network_name}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.main.id
  project       = var.project
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id  
  project       = var.project
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.id 
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_vpc_access_connector" "serverless_connector" {
  name          = "serverless-vpc-connector"
  region        = var.region
  network       = google_compute_network.main.name  
  ip_cidr_range = "10.8.0.0/28"                      
  project       = var.project
  min_throughput = 200
  max_throughput = 300 
}

resource "google_compute_firewall" "allow_cloudsql" {
  name    = "allow-cloudsql-access"
  network = google_compute_network.main.name
  project = var.project

  allow {
    protocol = "tcp"
    ports    = ["5432"]  
  }

  source_ranges = [
    google_vpc_access_connector.serverless_connector.ip_cidr_range  
  ]
}
