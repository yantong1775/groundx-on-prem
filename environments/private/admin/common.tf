locals {
  create_groundx        = var.create.all ? var.create.all : (
                        var.create.search ? var.create.search : (
                          var.create.ingest ? var.create.ingest : var.create.groundx
                        )
                      )
  create_layout         = var.create.all ? var.create.all : (
                        var.create.ingest ? var.create.ingest : var.create.layout
                      )
  create_layout_webhook = var.create.all ? var.create.all : (
                        var.create.ingest ? var.create.ingest : var.create.layout_webhook
                      )
  create_kafka          = var.create.all ? var.create.all : (
                        var.create.ingest ? var.create.ingest : var.create.kafka
                      )
  create_minio          = var.create.all ? var.create.all : (
                        var.create.search ? var.create.search : (
                          var.create.ingest ? var.create.ingest : var.create.minio
                        )
                      )
  create_mysql          = var.create.all ? var.create.all : (
                        var.create.search ? var.create.search : (
                          var.create.ingest ? var.create.ingest : var.create.mysql
                        )
                      )
  create_opensearch     = var.create.all ? var.create.all : (
                        var.create.search ? var.create.search : (
                          var.create.ingest ? var.create.ingest : var.create.opensearch
                        )
                      )
  create_pre_process    = var.create.all ? var.create.all : (
                        var.create.ingest ? var.create.ingest : var.create.pre_process
                      )
  create_process        = var.create.all ? var.create.all : (
                        var.create.ingest ? var.create.ingest : var.create.process
                      )
  create_queue          = var.create.all ? var.create.all : (
                        var.create.ingest ? var.create.ingest : var.create.queue
                      )
  create_ranker         = var.create.all ? var.create.all : (
                        var.create.search ? var.create.search : var.create.ranker
                      )
  create_redis          = var.create.all ? var.create.all : (
                        var.create.search ? var.create.search : (
                          var.create.ingest ? var.create.ingest : var.create.redis
                        )
                      )
  create_summary        = var.create.all ? var.create.all : (
                        var.create.ingest ? var.create.ingest : var.create.summary
                      )
  create_summary_client = var.create.all ? var.create.all : (
                        var.create.ingest ? var.create.ingest : var.create.summary_client
                      )
  create_upload         = var.create.all ? var.create.all : (
                        var.create.ingest ? var.create.ingest : var.create.upload
                      )

  create_none = (
                  var.create.all == false &&
                  var.create.ingest == false &&
                  var.create.search == false &&
                  var.create.groundx == false &&
                  var.create.kafka == false &&
                  var.create.layout == false &&
                  var.create.layout_webhook == false &&
                  var.create.minio == false &&
                  var.create.mysql == false &&
                  var.create.opensearch == false &&
                  var.create.pre_process == false &&
                  var.create.process == false &&
                  var.create.queue == false &&
                  var.create.ranker == false &&
                  var.create.redis == false &&
                  var.create.summary == false &&
                  var.create.summary_client == false &&
                  var.create.upload == false
                )

  is_openshift = var.cluster.type == "openshift"
}

provider "kubernetes" {
  config_path = var.cluster.kube_config_path
}

resource "kubernetes_namespace" "eyelevel" {
  metadata {
    name = var.app.namespace
  }
}

resource "kubernetes_storage_class_v1" "local_storage" {
  count = local.create_none ? 0 : 1

  metadata {
    name = var.app.pv_class
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

  depends_on = [tls_private_key.ca_key]

  private_key_pem = tls_private_key.ca_key[0].private_key_pem
  subject {
    common_name  = "Self-Signed Cluster Root CA"
    organization = var.app.namespace
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

  depends_on = [tls_private_key.service_key]

  private_key_pem = tls_private_key.service_key[0].private_key_pem

  subject {
    common_name  = "*.${var.app.namespace}.svc"
    organization = var.app.namespace
  }

  dns_names             = ["*.${var.app.namespace}.svc"]
}

resource "tls_locally_signed_cert" "service_cert" {
  count                 = local.create_none ? 0 : 1

  depends_on = [tls_cert_request.service_csr, tls_private_key.ca_key, tls_self_signed_cert.ca_cert]

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

  depends_on = [tls_locally_signed_cert.service_cert, kubernetes_namespace.eyelevel]

  metadata {
    name      = "${var.app.namespace}-cert"
    namespace = var.app.namespace
  }

  data = {
    "tls.crt" = tls_locally_signed_cert.service_cert[0].cert_pem
    "tls.key" = tls_private_key.service_key[0].private_key_pem
    "ca.crt"  = tls_self_signed_cert.ca_cert[0].cert_pem
  }

  type = "kubernetes.io/tls"
}