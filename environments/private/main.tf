locals {
  create_kafka = var.create_all ? var.create_all : var.create_kafka
  create_minio = var.create_all ? var.create_all : var.create_minio
  create_mysql = var.create_all ? var.create_all : var.create_mysql
  create_redis = var.create_all ? var.create_all : var.create_redis

  create_none = var.create_all == false && var.create_kafka == false && var.create_minio == false && var.create_mysql == false && var.create_redis == false
}

provider "kubernetes" {
  config_path = var.kube_config_path
}

resource "kubernetes_namespace" "eyelevel" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_storage_class_v1" "local_storage" {
  count = local.create_none ? 0 : 1

  metadata {
    name = var.pv_class
  }

  storage_provisioner = "kubernetes.io/no-provisioner"
  volume_binding_mode = "WaitForFirstConsumer"
}