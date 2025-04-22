resource "google_sql_database_instance" "default" {
  project       = var.project
  name             = var.name
  region           = var.region
  database_version = "POSTGRES_14"

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_network
    }
  }

  deletion_protection = false
}

resource "google_sql_user" "user" {
  project       = var.project
  name     = var.db_user
  instance = google_sql_database_instance.default.name
  password = var.db_password
}

resource "google_sql_database" "default_db" {
  name     = "cache"  
  instance = google_sql_database_instance.default.name
  project  = var.project
}

