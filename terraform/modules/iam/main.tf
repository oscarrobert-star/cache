resource "google_service_account" "cloud_run_sa" {
  account_id   = var.service_account_name
  display_name = "Cloud Run Service Account for ${var.environment} environment"
  project      = var.project
}

# Pub/Sub Access
resource "google_project_iam_member" "cloud_run_pubsub" {
  project = var.project
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Pub/Sub Subscriber Access
resource "google_project_iam_member" "cloud_run_pubsub_subscriber" {
  project = var.project
  role    = "roles/pubsub.subscriber"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Secret Manager Access
resource "google_project_iam_member" "cloud_run_secrets" {
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Cloud SQL Access
resource "google_project_iam_member" "cloud_run_sql" {
  project = var.project
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Logging
resource "google_project_iam_member" "cloud_run_logging" {
  project = var.project
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}
