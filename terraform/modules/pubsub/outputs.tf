output "topic_name" {
  description = "Topic name"
  value = google_pubsub_topic.topic.name
}

output "sub_name" {
  description = "subscription name"
  value = google_pubsub_subscription.sub.name
}