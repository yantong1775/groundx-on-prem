locals {
  cluster_exists = var.cluster_id != null && var.cluster_id != "" ? true : false
}

data "aws_eks_cluster" "cluster" {
  count = local.cluster_exists ? 1 : 0

  name = var.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  count = local.cluster_exists ? 1 : 0

  name = var.cluster_id
}

provider "kubernetes" {
  host                   = local.cluster_exists ? data.aws_eks_cluster.cluster[0].endpoint : ""
  cluster_ca_certificate = local.cluster_exists ? base64decode(data.aws_eks_cluster.cluster[0].certificate_authority[0].data) : ""
  token                  = local.cluster_exists ? data.aws_eks_cluster_auth.cluster[0].token : ""
}