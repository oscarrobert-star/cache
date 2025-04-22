resource "google_cloud_run_service" "app" {
  name                       = var.name
  location                   = var.region
  project                    = var.project
  autogenerate_revision_name = true

  template {
    spec {
      containers {
        image = var.image

        env {
          name  = "ENV"
          value = var.environment
        }

        env {
          name  = "DB_SECRET_NAME"
          value = var.db_secret_name
        }

        env {
          name  = "GOOGLE_CLOUD_PROJECT"
          value = var.project
        }

        env {
          name  = "DB_HOST"
          value = var.db_host
        }

        env {
          name  = "PUBSUB_TOPIC"
          value = var.pubsub_topic
        }

        env {
          name  = "DB_NAME"
          value = var.db_name
        }

        env {
          name = "PUBSUB_SUBSCRIPTION"
          value = var.pubsub_subscription
        }
      }
      service_account_name = var.service_account_email
    }

    metadata {
      annotations = {
        "run.googleapis.com/cloudsql-instances"   = var.cloudsql_connection
        "run.googleapis.com/vpc-access-connector" = var.serverless_connector_id
        "run.googleapis.com/vpc-access-egress"    = "all"
        "autoscaling.knative.dev/minScale"        = "0"
        "autoscaling.knative.dev/maxScale"        = "4"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location = google_cloud_run_service.app.location
  project  = google_cloud_run_service.app.project
  service  = google_cloud_run_service.app.name

  policy_data = data.google_iam_policy.noauth.policy_data
}
