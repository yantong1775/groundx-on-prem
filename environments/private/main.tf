provider "kubernetes" {
  config_path = var.kube_config_path
}

resource "kubernetes_namespace" "eyelevel" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_storage_class_v1" "local_storage" {
  metadata {
    name = var.pv_class
  }

  storage_provisioner = "kubernetes.io/no-provisioner"
  volume_binding_mode = "WaitForFirstConsumer"
}