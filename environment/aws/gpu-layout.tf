resource "aws_eks_node_group" "gpu_layout_nodes" {
  depends_on = [
    aws_eks_node_group.cpu_only_nodes,
    aws_iam_role_policy_attachment.eyelevel_nodes_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eyelevel_nodes_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eyelevel_nodes_AmazonEC2ContainerRegistryReadOnly,
  ]

  node_group_name                   = var.nodes.node_groups.layout_nodes.name
  cluster_name                      = var.cluster.name

  node_role_arn                     = aws_iam_role.eyelevel_nodes.arn
  subnet_ids                        = var.environment.subnets

  ami_type                          = var.nodes.node_groups.layout_nodes.ami_type
  disk_size                         = var.nodes.node_groups.layout_nodes.disk_size
  instance_types                    = var.nodes.node_groups.layout_nodes.instance_types

  remote_access {
    ec2_ssh_key                     = var.environment.ssh_key_name
    source_security_group_ids       = var.environment.vpc_security_group_ids
  }

  scaling_config {
    desired_size                    = var.nodes.node_groups.layout_nodes.desired_size
    max_size                        = var.nodes.node_groups.layout_nodes.max_size
    min_size                        = var.nodes.node_groups.layout_nodes.min_size
  }

  update_config {
    max_unavailable                 = 1
  }

  labels                            = var.nodes.node_groups.layout_nodes.labels

  tags = {
    Environment                     = var.environment.environment
    Name                            = var.nodes.node_groups.layout_nodes.name
    Terraform                       = "true"
  }
}