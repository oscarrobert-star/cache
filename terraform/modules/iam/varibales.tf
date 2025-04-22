variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., staging, prod)"
  type        = string
}

variable "service_account_name" {
  description = "Name of the service account (without domain suffix)"
  type        = string
  default     = "cloud-run-app"
}
