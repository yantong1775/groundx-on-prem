output "db_subnet_group_name" {
  description = "Name of subnet group to apply to database"
  value = ""
}

output "network_cidr" {
  description = "The CIDR block for the network (VPC, VNet, etc.)"
  value       = var.network_cidr
}

output "subnet_cidrs" {
  description = "List of CIDR blocks for subnets"
  value       = var.subnet_cidrs
}

output "security_group_ids" {
  description = "List of VPC security group IDs"
  value       = var.security_group_ids
}

output "security_rules" {
  description = "Security rules for creating new security groups"
  value       = var.security_rules
}

output "subnet_ids" {
  description = "List of subnet IDs"
  value       = var.subnet_ids
}

