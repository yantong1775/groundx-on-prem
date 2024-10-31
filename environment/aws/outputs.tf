/*output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.eyelevel.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane"
  value       = aws_eks_cluster.eyelevel.cluster_security_group_id
}

output "node_security_group_id" {
  description = "Security group ids for cluster nodes"
  value       = aws_eks_cluster.eyelevel.node_security_group_id
}

output "region" {
  description = "AWS region"
  value       = var.environment.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = aws_eks_cluster.eyelevel.cluster_name
}*/