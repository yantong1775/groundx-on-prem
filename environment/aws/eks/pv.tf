resource "kubernetes_storage_class" "eyelevel_ebs_pv" {
  depends_on = [module.eyelevel_eks]

  metadata {
    name = "${var.cluster.name}-${var.cluster_internal.pv.name}"
  }

  storage_provisioner  = "ebs.csi.aws.com"
  reclaim_policy       = "Delete"
  volume_binding_mode  = "WaitForFirstConsumer"

  parameters = {
    type = var.cluster_internal.pv.type
  }
}