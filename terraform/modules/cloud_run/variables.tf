# variables.tf
variable "name" {}
variable "region" {}
variable "image" {}
variable "environment" {}
variable "cloudsql_connection" {}
variable "project" {
  description = "The GCP project ID"
  type        = string
}
variable "service_account_email" {
  description = "IAM service account email to use for Cloud Run"
  type        = string
}
variable "db_secret_name" {}
variable "db_host" {}
variable "pubsub_topic" {}
variable "db_name" {}
variable "serverless_connector_id" {}
variable "pubsub_subscription" {}