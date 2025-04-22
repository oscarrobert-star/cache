variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for the Artifact Registry"
  type        = string
}

variable "repo_id" {
  description = "Name of the Docker repo"
  type        = string
}

variable "description" {
  description = "Description of the repository"
  type        = string
  default     = "Docker artifact registry for app deployments"
}
