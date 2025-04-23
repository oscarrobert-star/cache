provider "google" {
  project = var.project
  region  = var.region
}

# VPC & Subnet
module "vpc" {
  source       = "../../modules/vpc"
  project      = var.project
  region       = var.region
  network_name = var.network_name
  subnet_cidr  = "10.10.0.0/24"
}

# Cloud SQL for PostgreSQL
module "cloud_sql" {
  source      = "../../modules/cloud_sql"
  project     = var.project
  region      = var.region
  name        = "production-postgres"
  vpc_network = module.vpc.network_self_link
  db_user     = "cache"
  db_password = var.db_password

  depends_on = [module.vpc]
}

# Pub/Sub
module "pubsub" {
  source      = "../../modules/pubsub"
  project     = var.project
  topic_name  = "production-events"
  environment = "production"
}

# Secrets (DB credentials example)
module "db_secret" {
  source  = "../../modules/secrets"
  project = var.project
  region  = var.region
  name    = "production-db-password"
  value   = var.db_password
}

# IAM for Cloud Run
module "iam" {
  source               = "../../modules/iam"
  project              = var.project
  environment          = "production"
  service_account_name = "production-cloud-run-sa"
}

# Cloud Run App
module "cloud_run_app" {
  source                = "../../modules/cloud_run"
  project               = var.project
  region                = var.region
  name                  = "production-app"
  image                 = var.image
  environment           = "production"
  cloudsql_connection   = module.cloud_sql.connection_name
  serverless_connector_id = module.vpc.serverless_connector_id
  service_account_email = module.iam.service_account_email
  db_secret_name        = module.db_secret.name
  db_host               = module.cloud_sql.db_host
  pubsub_topic          = module.pubsub.topic_name
  pubsub_subscription   = module.pubsub.sub_name
  db_name               = module.cloud_sql.db_name

  depends_on = [module.cloud_sql, module.iam]
}

# artifact_registry
module "artifact_registry" {
  source      = "../../modules/artifact_registry"
  project     = var.project
  region      = var.region
  repo_id     = "production-app-repo"
  description = "Production Docker repo for app images"
}
