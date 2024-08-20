variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "db_name" {
  type        = string
  description = "The name of the MySQL database"
}

variable "db_username" {
  type        = string
  description = "The username for the MySQL database"
}

variable "db_password" {
  type        = string
  description = "The password for the MySQL database"
  sensitive   = true
}

variable "db_instance_identifier" {
  description = "The identifier for the MySQL database instance"
  type        = string
}

variable "db_instance_type" {
  type        = string
  description = "The instance type for the database"
}

variable "db_allocated_storage" {
  type        = number
  description = "The size of the database storage in GB"
}