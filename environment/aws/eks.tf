module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = ">= 20.0"

  cluster_name                    = var.cluster.name

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  enable_cluster_creator_admin_permissions = true
  subnet_ids                      = var.environment.subnets

  eks_managed_node_groups = {
    cpu_memory_nodes = {
      name                        = var.nodes.node_groups.cpu_memory_nodes.name

      key_name                    = var.environment.ssh_key_name

      ami_type                    = var.nodes.node_groups.cpu_memory_nodes.ami_type
      disk_size                   = var.nodes.node_groups.cpu_memory_nodes.disk_size
      instance_types              = var.nodes.node_groups.cpu_memory_nodes.instance_types

      desired_size                = var.nodes.node_groups.cpu_memory_nodes.desired_size
      max_size                    = var.nodes.node_groups.cpu_memory_nodes.max_size
      min_size                    = var.nodes.node_groups.cpu_memory_nodes.min_size

      labels                      = var.nodes.node_groups.cpu_memory_nodes.labels

      tags = {
        Environment               = var.environment.environment
        Name                      = var.nodes.node_groups.cpu_memory_nodes.name
        Terraform                 = "true"
      }
    }
    cpu_only_nodes = {
      name                        = var.nodes.node_groups.cpu_only_nodes.name

      key_name                    = var.environment.ssh_key_name

      ami_type                    = var.nodes.node_groups.cpu_only_nodes.ami_type
      disk_size                   = var.nodes.node_groups.cpu_only_nodes.disk_size
      instance_types              = var.nodes.node_groups.cpu_only_nodes.instance_types

      desired_size                = var.nodes.node_groups.cpu_only_nodes.desired_size
      max_size                    = var.nodes.node_groups.cpu_only_nodes.max_size
      min_size                    = var.nodes.node_groups.cpu_only_nodes.min_size

      labels                      = var.nodes.node_groups.cpu_only_nodes.labels

      tags = {
        Environment               = var.environment.environment
        Name                      = var.nodes.node_groups.cpu_only_nodes.name
        Terraform                 = "true"
      }
    }
    gpu_layout_nodes = {
      name                        = var.nodes.node_groups.layout_nodes.name

      key_name                    = var.environment.ssh_key_name

      ami_type                    = var.nodes.node_groups.layout_nodes.ami_type
      disk_size                   = var.nodes.node_groups.layout_nodes.disk_size
      instance_types              = var.nodes.node_groups.layout_nodes.instance_types

      desired_size                = var.nodes.node_groups.layout_nodes.desired_size
      max_size                    = var.nodes.node_groups.layout_nodes.max_size
      min_size                    = var.nodes.node_groups.layout_nodes.min_size

      labels                      = var.nodes.node_groups.layout_nodes.labels

      tags = {
        Environment               = var.environment.environment
        Name                      = var.nodes.node_groups.layout_nodes.name
        Terraform                 = "true"
      }
    }
    gpu_ranker_nodes = {
      name                        = var.nodes.node_groups.ranker_nodes.name

      key_name                    = var.environment.ssh_key_name

      ami_type                    = var.nodes.node_groups.ranker_nodes.ami_type
      disk_size                   = var.nodes.node_groups.ranker_nodes.disk_size
      instance_types              = var.nodes.node_groups.ranker_nodes.instance_types

      desired_size                = var.nodes.node_groups.ranker_nodes.desired_size
      max_size                    = var.nodes.node_groups.ranker_nodes.max_size
      min_size                    = var.nodes.node_groups.ranker_nodes.min_size

      labels                      = var.nodes.node_groups.ranker_nodes.labels

      tags = {
        Environment               = var.environment.environment
        Name                      = var.nodes.node_groups.ranker_nodes.name
        Terraform                 = "true"
      }
    }
    gpu_summary_nodes = {
      name                        = var.nodes.node_groups.summary_nodes.name

      key_name                    = var.environment.ssh_key_name

      ami_type                    = var.nodes.node_groups.summary_nodes.ami_type
      disk_size                   = var.nodes.node_groups.summary_nodes.disk_size
      instance_types              = var.nodes.node_groups.summary_nodes.instance_types

      desired_size                = var.nodes.node_groups.summary_nodes.desired_size
      max_size                    = var.nodes.node_groups.summary_nodes.max_size
      min_size                    = var.nodes.node_groups.summary_nodes.min_size

      labels                      = var.nodes.node_groups.summary_nodes.labels

      tags = {
        Environment               = var.environment.environment
        Name                      = var.nodes.node_groups.summary_nodes.name
        Terraform                 = "true"
      }
    }
  }
}

resource "null_resource" "wait_for_eks" {
  depends_on = [module.eks]

  provisioner "local-exec" {
    command  = "aws eks update-kubeconfig --region ${var.environment.region} --name ${var.cluster.name}"
  }
}