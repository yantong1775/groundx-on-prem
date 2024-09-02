resource "helm_release" "groundx_service" {
  count = local.create_groundx ? 1 : 0

  depends_on = [kubernetes_namespace.eyelevel]

  name       = "${var.groundx_service}-cluster"
  namespace  = var.namespace
  chart      = "${path.module}/../../modules/groundx/helm_chart"

  values = [
    yamlencode({
      image = {
        pull       = var.groundx_image_pull
        repository = var.groundx_image_url
        tag        = var.groundx_image_tag
      }
      service = {
        name      = var.groundx_service
        namespace = var.namespace
        version   = var.groundx_version
      }
    })
  ]
}