variable "project" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Deployment region"
  default     = "europe-west1"
}

variable "db_password" {
  description = "Postgres DB password"
  type        = string
}

variable "image" {
  description = "Docker image URL (e.g. gcr.io/project/image:tag)"
  type        = string
}
variable "environment" {
  description = "Environment name (e.g. dev, staging, prod)"
  type        = string
}

variable "network_name" {
  description = "VPC network name"
  type        = string
  default     = "staging-network"
  
}