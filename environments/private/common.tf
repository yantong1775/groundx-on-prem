locals {
  create_groundx    = var.create_all ? var.create_all : var.create_groundx
  create_kafka      = var.create_all ? var.create_all : var.create_kafka
  create_minio      = var.create_all ? var.create_all : var.create_minio
  create_mysql      = var.create_all ? var.create_all : var.create_mysql
  create_opensearch = var.create_all ? var.create_all : var.create_opensearch
  create_redis      = var.create_all ? var.create_all : var.create_redis

  create_none = var.create_all == false && var.create_groundx == false && var.create_kafka == false && var.create_minio == false &&var.create_mysql == false && var.create_redis == false
}

provider "kubernetes" {
  config_path = var.kube_config_path
}

resource "kubernetes_namespace" "eyelevel" {
  metadata {
    name = var.namespace
  }
}

data "external" "get_uid_gid" {
  depends_on = [kubernetes_namespace.eyelevel]

  program = ["sh", "-c", <<-EOT
    kubectl get namespace ${var.namespace} -o jsonpath='{.metadata.annotations.openshift\.io/sa\.scc\.uid-range}' | cut -d'/' -f1 | xargs -I {} jq -n --arg uid {} --arg gid {} '{"UID": $uid, "GID": $gid}'
  EOT
  ]
}

resource "kubernetes_storage_class_v1" "local_storage" {
  count = local.create_none ? 0 : 1

  metadata {
    name = var.pv_class
  }

  storage_provisioner = "kubernetes.io/no-provisioner"
  volume_binding_mode = "WaitForFirstConsumer"
}

resource "tls_private_key" "ca_key" {
  count     = local.create_none ? 0 : 1

  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "ca_cert" {
  count           = local.create_none ? 0 : 1

  private_key_pem = tls_private_key.ca_key[0].private_key_pem
  subject {
    common_name  = "Self-Signed Cluster Root CA"
    organization = var.namespace
  }

  validity_period_hours = 87600  # 10 years
  early_renewal_hours   = 720    # 30 days
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "crl_signing"
  ]
}

resource "tls_private_key" "service_key" {
  count     = local.create_none ? 0 : 1

  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_cert_request" "service_csr" {
  count           = local.create_none ? 0 : 1

  private_key_pem = tls_private_key.service_key[0].private_key_pem

  subject {
    common_name  = "*.${var.namespace}.svc"
    organization = var.namespace
  }

  dns_names             = ["*.${var.namespace}.svc"]
}

resource "tls_locally_signed_cert" "service_cert" {
  count                 = local.create_none ? 0 : 1

  cert_request_pem      = tls_cert_request.service_csr[0].cert_request_pem
  ca_private_key_pem    = tls_private_key.ca_key[0].private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca_cert[0].cert_pem

  validity_period_hours = 8760  # 1 year
  early_renewal_hours   = 720   # 30 days

  allowed_uses = [
    "digital_signature",
    "key_encipherment",
    "server_auth"
  ]
}

resource "kubernetes_secret" "ssl_cert" {
  count = local.create_none ? 0 : 1

  depends_on = [kubernetes_namespace.eyelevel]

  metadata {
    name      = "${var.namespace}-cert"
    namespace = var.namespace
  }

  data = {
    "tls.crt" = tls_locally_signed_cert.service_cert[0].cert_pem
    "tls.key" = tls_private_key.service_key[0].private_key_pem
    "ca.crt"  = tls_self_signed_cert.ca_cert[0].cert_pem
  }

  type = "kubernetes.io/tls"
}