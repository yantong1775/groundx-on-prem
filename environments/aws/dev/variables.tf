# GLOBAL

variable "environment" {
  description = "The environment name (e.g., dev, staging, prod)"
  type        = string
}


# VPC

variable "region" {
  description = "The AWS region to deploy in"
  type        = string
  default     = "us-east-2"
}

variable "vpc_id" {
  description = "The ID for an existing VPC"
  type        = string
  default     = null
}

# NETWORK

variable "create_security_groups" {
  description = "Whether to create new security groups"
  type        = bool
  default     = false
}

variable "create_subnets" {
  description = "Whether to create new subnets"
  type        = bool
  default     = false
}

variable "create_vpc" {
  description = "Whether to create a new VPC"
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "The VPC security group IDs for resources"
  type        = list(string)
}

variable "subnet_ids" {
  description = "The subnet IDs for resources"
  type        = list(string)
}

# DATABASE

variable "db_name" {
  description = "The name of the MySQL database"
  type        = string
  default     = "eyelevel"
}

variable "db_username" {
  description = "The username for the MySQL database"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "The password for the MySQL database"
  type        = string
  sensitive   = true
}

variable "db_instance_identifier" {
  description = "The identifier for the MySQL database instance"
  type        = string
}

variable "db_instance_type" {
  description = "The instance type for the MySQL database"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "The allocated storage for the MySQL database (in GB)"
  type        = number
  default     = 20
}