# variables.tf
variable "topic_name" {}
variable "project" {
  description = "The GCP project ID"
  type        = string
}
variable "environment" {
  description = "The environment (e.g., dev, prod)"
  type        = string
}


