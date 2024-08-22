output "ingress_cidr" {
  description = "The CIDR block for network ingress"
  value       = var.ingress_cidr
}

output "network_cidr" {
  description = "The CIDR block for the network (VPC, VNet, etc.)"
  value       = var.network_cidr
}

output "subnet_cidrs" {
  description = "List of CIDR blocks for subnets"
  value       = var.subnet_cidrs
}

output "subnet_ids" {
  description = "List of subnet IDs"
  value       = var.subnet_ids
}

output "vpc_id" {
  description = "The ID of the current VPC"
  value       = var.vpc_id
}