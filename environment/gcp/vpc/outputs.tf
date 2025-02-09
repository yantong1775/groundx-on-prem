output "ssh_firewall" {
  description = "firewall ID that allows SSH from VPC subnets only, add this to env.tfvars to enable SSH"
  value       = google_compute_firewall.allow-ssh-only-ingress.self_link
}

output "subnets" {
  description = "Subnets for EyeLevel VPC, add these to env.tfvars"
  value       = module.eyelevel_vpc.subnets
}

output "vpc_id" {
  description = "VPC ID for EyeLevel VPC, add this to env.tfvars"
  value       = module.eyelevel_vpc.network_id
}