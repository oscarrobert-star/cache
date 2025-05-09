# variables.tf
variable "name" {}
variable "value" {}
variable "project" {
  description = "The GCP project ID"
  type        = string
}
variable "region" {
  description = "The GCP region"
  type        = string  
}