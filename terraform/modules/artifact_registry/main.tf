resource "google_artifact_registry_repository" "docker_repo" {
  provider = google
  project  = var.project
  location = var.region

  repository_id = var.repo_id
  description   = var.description
  format        = "DOCKER"

  docker_config {
    immutable_tags = false
  }
}
