provider "kubernetes" {
  config_path = var.cluster.kube_config_path
}

locals {
  is_openshift = var.cluster.type == "openshift"
}