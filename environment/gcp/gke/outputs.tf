output "cluster_endpoint" {
  description = "Endpoint for GKE control plane"
  value       = length(module.eyelevel_gke) > 0 ? module.eyelevel_gke[0].endpoint : "(not created)"
}