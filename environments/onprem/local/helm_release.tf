provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "kubernetes_namespace" "eyelevel" {
  metadata {
    name = "eyelevel"
  }
}

resource "kubernetes_secret" "mysql_secret" {
  metadata {
    name      = "mysql-secret"
    namespace = "eyelevel"
  }

  data = {
    MYSQL_DATABASE      = var.db_name
    MYSQL_USER          = var.db_username
    MYSQL_PASSWORD      = var.db_password
    MYSQL_ROOT_PASSWORD = var.db_root_password
  }
}

data "external" "get_uid_gid" {
  program = ["sh", "-c", <<-EOT
    kubectl get namespace ${kubernetes_namespace.eyelevel.metadata[0].name} -o jsonpath='{.metadata.annotations.openshift\.io/sa\.scc\.uid-range}' | cut -d'/' -f1 | xargs -I {} jq -n --arg uid {} --arg gid {} '{"mysqlUID": $uid, "mysqlGID": $gid}'
  EOT
  ]
}

output "mysql_uid" {
  value = data.external.get_uid_gid.result.mysqlUID
}

output "mysql_gid" {
  value = data.external.get_uid_gid.result.mysqlGID
}

resource "helm_release" "mysql" {
  name       = "mysql"
  chart      = "${path.module}/../../../modules/mysql/helm_chart"
  namespace  = "eyelevel"

  values = [
    file("${path.module}/../../../modules/mysql/helm_chart/values.yaml"),
    yamlencode({
      securityContext = {
        runAsUser = data.external.get_uid_gid.result.mysqlUID
        runAsGroup = data.external.get_uid_gid.result.mysqlGID
        fsGroup = data.external.get_uid_gid.result.mysqlGID
      }
    })
  ]
}