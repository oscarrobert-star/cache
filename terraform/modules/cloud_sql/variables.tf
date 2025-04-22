# variables.tf
variable "name" {
  description = "The name of the Cloud SQL instance"
  type        = string
  default     = "cache"
}
variable "region" {
  description = "The GCP region"
  type        = string
}
variable "vpc_network" {
  description = "The VPC network to use for the Cloud SQL instance"
  type        = string
}
variable "db_user" {
  description = "The database user name"
  type        = string
  default     = "cache"
}
variable "db_password" {
  description = "The password for the database user"
  type        = string
  sensitive   = true
}
variable "project" {
  description = "The GCP project ID"
  type        = string
}