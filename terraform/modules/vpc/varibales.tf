# variables.tf

variable "project" {
  description = "GCP project ID"
  type        = string
}
variable "network_name" {
  description = "Name of the VPC network"
  type        = string
}
variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
}
variable "region" {
  description = "GCP region for the VPC"
  type        = string
}