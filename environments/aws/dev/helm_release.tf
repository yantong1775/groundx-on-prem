provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}

resource "helm_release" "mysql" {
  name       = "mysql"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mysql"
  namespace  = "default"

  values = [
    file("${path.module}/../../../modules/mysql/helm_chart/values.yaml"),
    <<EOF
mysqlRootPassword: "${var.db_password}"
EOF
  ]
}