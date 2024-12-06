resource "helm_release" "summary_api_lb" {
  count = local.create_summary ? 0 : 0

  depends_on = [helm_release.summary_api_service]

  name       = "${var.summary_internal.service}-cluster-lb"
  namespace  = var.app_internal.namespace
  chart      = "${local.module_path}/load-balancer/load-balancer/helm_chart"

  values = [
    yamlencode({
      name      = "${var.summary_internal.service}-cluster-lb"
      namespace = var.app_internal.namespace
      port      = var.groundx.load_balancer.port
      target    = "${var.summary_internal.service}-api"
      timeout   = 240
    })
  ]
}