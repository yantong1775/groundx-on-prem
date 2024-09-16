provider "aws" {
  region = var.region
}

locals {
  use_existing_vpc = var.vpc_id != null && !var.create_vpc
  use_existing_subnets = !var.create_subnets || !var.create_vpc
  vpc_id = local.use_existing_vpc ? var.vpc_id : aws_vpc.eyelevel[0].id

  cluster_id = var.cluster_id
}

module "eks" {
  count = local.cluster_id == null ? 1 : 0

  source                 = "terraform-aws-modules/eks/aws"
  version                = "20.24.0"
  cluster_name           = var.cluster_name
  cluster_version        = var.cluster_version
  subnet_ids             = module.network.subnet_ids
  vpc_id                 = module.network.vpc_id

  cluster_endpoint_public_access = var.ingress_cidr == "0.0.0.0/0" ? true : false
  cluster_endpoint_private_access = true
  
  eks_managed_node_groups = {
    mysql = {
      min_size     = 1
      max_size     = 3
      desired_size = 1

      instance_types = [var.db_instance_type]

      security_groups = [aws_security_group.eks_node_sg.id]

      labels = {
        app = "mysql"
      }

      taints = [{
        key    = "app"
        value  = "mysql"
        effect = "NO_SCHEDULE"
      }]
    }
  }
}

output "cluster_id" {
  description = "The ID of the EKS cluster"
  value       = local.cluster_id != null ? local.cluster_id : (try(module.eks[0].cluster_id, "Cluster ID not available"))
}