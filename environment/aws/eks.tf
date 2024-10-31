terraform {
  backend "local" {
    path                                   = "terraform.tfstate"
  }
}

resource "aws_eks_cluster" "eyelevel" {
  depends_on = [aws_iam_role_policy_attachment.eyelevel_AmazonEKSClusterPolicy]

  //source                                   = "terraform-aws-modules/eks/aws"
  //version                                  = ">= 20.8.5"

  name                                       = var.cluster.name
  role_arn                                   = aws_iam_role.eyelevel.arn

  //cluster_version                            = var.environment_internal.eks_version

  vpc_config {
    subnet_ids                               = var.environment.subnets
    //vpc_id                                   = var.environment.vpc_id
  }

  //subnet_ids                                 = var.environment.subnets
  //vpc_id                                     = var.environment.vpc_id

  //authentication_mode                      = "API_AND_CONFIG_MAP"
  //cluster_endpoint_public_access           = true
  //enable_cluster_creator_admin_permissions = true
}

resource "null_resource" "wait_for_eks" {
  depends_on                               = [aws_eks_cluster.eyelevel]

  provisioner "local-exec" {
    command                                = "aws eks update-kubeconfig --region ${var.environment.region} --name ${var.cluster.name}"
  }
}