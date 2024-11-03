data "aws_caller_identity" "current" {}

resource "kubernetes_config_map" "aws_auth" {
  count = 0

  depends_on = [null_resource.wait_for_eks]

  metadata {
    name             = "aws-auth"
    namespace        = "kube-system"
  }

  data               = {
    mapRoles         = yamlencode(
      concat(
        [
          {
            rolearn  = module.eks.cluster_iam_role_arn
            username = "system:node:{{EC2PrivateDNSName}}"
            groups   = ["system:masters"]
          },
          {
            rolearn  = module.eks.eks_managed_node_groups["cpu_memory_nodes"].iam_role_arn
            username = "system:node:{{EC2PrivateDNSName}}"
            groups   = ["system:masters"]
          }
        ], [
          for idx, rolearn in var.environment.cluster_role_arns : {
            rolearn  = rolearn
            username = "cluster-role-${idx}"
            groups   = ["system:masters"]
          }
        ]
      )
    )

    mapUsers         = yamlencode([
      {
        userarn      = data.aws_caller_identity.current.arn
        username     = data.aws_caller_identity.current.user_id
        groups       = ["system:masters"]
      }
    ])
  }
}

resource "kubernetes_storage_class" "ebs_sc" {
  count = 0

  depends_on = [aws_eks_addon.aws_ebs_csi_driver]

  metadata {
    name = "ebs-gp2"
  }

  storage_provisioner  = "ebs.csi.aws.com"
  reclaim_policy       = "Delete"
  volume_binding_mode  = "WaitForFirstConsumer"

  parameters = {
    type = "gp2"
  }
}