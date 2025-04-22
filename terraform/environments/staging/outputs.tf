# output "cloud_run_url" {
#   value = module.cloud_run_app.url
# }
# output "cloud_sql_instance" {
#   value = module.cloud_sql.instance_name
# }
# output "cloud_sql_user" {
#   value = module.cloud_sql.user_name
# }
# output "artifact_repo_url" {
#   value = module.artifact_registry.repo_url
# }

output "db_name" {
  description = "database name"
  value       = module.cloud_sql.db_name
  
}

output "sub_name" {
  description = "subscription name" 
  value       = module.pubsub.sub_name
}