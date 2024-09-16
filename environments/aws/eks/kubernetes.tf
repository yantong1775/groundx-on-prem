locals {
  cluster_exists = var.cluster_id != null && var.cluster_id != "" ? true : false
  admin_role_mapping = var.admin_role_arn != null && var.admin_role_arn != "" ? [{
    rolearn  = var.admin_role_arn
    username = "admin"
    groups   = ["system:masters"]
  }] : []
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

resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = yamlencode(concat(
      local.admin_role_mapping,
      flatten([
        for ng in module.eks[0].eks_managed_node_groups : [
          {
            rolearn  = ng.iam_role_arn
            username = "system:node:{{EC2PrivateDNSName}}"
            groups   = ["system:bootstrappers", "system:nodes"]
          }
        ]
      ])
    ))
  }
}