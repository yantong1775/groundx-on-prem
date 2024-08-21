locals {
  cluster_exists = var.cluster_id != null && var.cluster_id != "" ? true : false
}

data "aws_eks_cluster" "cluster" {
  count = local.cluster_exists ? 1 : 0

  name = var.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  count = local.cluster_exists ? 1 : 0

  name = var.cluster_id
}

provider "kubernetes" {
  host                   = local.cluster_exists ? data.aws_eks_cluster.cluster[0].endpoint : ""
  cluster_ca_certificate = local.cluster_exists ? base64decode(data.aws_eks_cluster.cluster[0].certificate_authority[0].data) : ""
  token                  = local.cluster_exists ? data.aws_eks_cluster_auth.cluster[0].token : ""
}

resource "kubernetes_secret" "mysql" {
  count = local.cluster_exists ? 1 : 0

  metadata {
    name = "mysql-secret"
  }

  data = {
    mysql-root-password = var.db_password
  }
}

resource "kubernetes_config_map" "mysql" {
  count = local.cluster_exists ? 1 : 0

  metadata {
    name = "mysql-config"
  }

  data = {
    mysql-database = var.db_name
  }
}

resource "kubernetes_deployment" "mysql" {
  count = local.cluster_exists ? 1 : 0

  metadata {
    name = "mysql"
    labels = {
      app = "mysql"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "mysql"
      }
    }

    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }

      spec {
        container {
          name  = "mysql"
          image = "mysql:8.0"

          port {
            container_port = 3306
          }

          env {
            name = "MYSQL_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.mysql[0].metadata[0].name
                key  = "mysql-root-password"
              }
            }
          }

          env {
            name = "MYSQL_DATABASE"
            value_from {
              config_map_key_ref {
                name = kubernetes_config_map.mysql[0].metadata[0].name
                key  = "mysql-database"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "mysql" {
  count = local.cluster_exists ? 1 : 0

  metadata {
    name = "mysql"
  }

  spec {
    selector = {
      app = "mysql"
    }

    port {
      port     = 3306
      protocol = "TCP"
    }
  }
}