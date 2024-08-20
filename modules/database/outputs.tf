output "db_allocated_storage" {
  description = "The allocated storage for the database"
  value       = var.db_allocated_storage
}

output "db_instance_identifier" {
  description = "The identifier for the MySQL database instance"
  value       = var.db_instance_identifier
}

output "db_instance_type" {
  description = "The instance type for the database"
  value       = var.db_instance_type
}

output "db_name" {
  description = "The name of the database"
  value       = var.db_name
}

output "db_username" {
  description = "The username for the database"
  value       = var.db_username
}

output "db_password" {
  description = "The password for the database"
  value       = var.db_password
}