output "subnets" {
  description = "Subnets for EyeLevel VPC, add these to env.tfvars"
  value       = module.eyelevel_vpc.private_subnets
}

output "vpc_id" {
  description = "VPC ID for EyeLevel VPC, add this to env.tfvars"
  value       = module.eyelevel_vpc.vpc_id
}