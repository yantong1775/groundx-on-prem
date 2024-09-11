data "external" "get_uid_gid" {
  count = local.is_openshift ? 1 : 0

  depends_on = [kubernetes_namespace.eyelevel]

  program = ["sh", "-c", <<-EOT
    kubectl get namespace ${var.namespace} -o jsonpath='{.metadata.annotations.openshift\.io/sa\.scc\.uid-range}' | cut -d'/' -f1 | xargs -I {} jq -n --arg uid {} --arg gid {} '{"UID": $uid, "GID": $gid}'
  EOT
  ]
}

resource "helm_release" "groundx_route_lb" {
  count = local.is_openshift ? 1 : 0

  depends_on = [helm_release.groundx_service]

  name       = "${var.groundx_service}-cluster-route"
  namespace  = var.namespace
  chart      = "${path.module}/../../../modules/load-balancer/route/helm_chart"

  values = [
    yamlencode({
      name      = "${var.groundx_service}-cluster-route"
      namespace = var.namespace
      target    = "${var.groundx_service}"
    })
  ]
}