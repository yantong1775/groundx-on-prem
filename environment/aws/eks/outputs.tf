output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eyelevel_eks.cluster_endpoint
}