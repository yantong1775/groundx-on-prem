data "aws_caller_identity" "current" {}

resource "kubernetes_config_map" "aws_auth" {
  depends_on         = [aws_eks_cluster.eyelevel]

  metadata {
    name             = "aws-auth"
    namespace        = "kube-system"
  }

  data               = {
    mapRoles         = yamlencode(
      concat(
        [
          {
            rolearn  = aws_iam_role.eyelevel_nodes.arn
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
