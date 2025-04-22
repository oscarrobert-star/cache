resource "google_pubsub_topic" "topic" {
  name    = var.topic_name
  project = var.project
  labels = {
    environment = var.environment
  }
}

resource "google_pubsub_subscription" "sub" {
  name    = "${var.topic_name}-sub"
  topic   = google_pubsub_topic.topic.name
  project = var.project

}
