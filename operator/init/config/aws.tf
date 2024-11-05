resource "helm_release" "create_ldconfig_symlink" {
  count = 0

  name       = "create-ldconfig-symlink"
  namespace  = "kube-system"
  chart      = "${local.module_path}/config/helm_chart"
}