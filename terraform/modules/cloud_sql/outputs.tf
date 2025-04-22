output "connection_name" {
  description = "Cloud SQL connection name in format project:region:instance"
  value       = google_sql_database_instance.default.connection_name
}
output "db_name" {
  description = "Database name"
  value       = google_sql_database.default_db.name
}

output "db_host" {
  description = "database private ip"
  value       = google_sql_database_instance.default.private_ip_address
}
