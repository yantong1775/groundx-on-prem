resource "kubernetes_secret" "config_yaml" {
  count = local.create_none ? 0 : 1

  depends_on = [kubernetes_namespace.eyelevel]

  metadata {
    name      = "config-yaml-secret"
    namespace = var.namespace
  }

  data = {
    namespace = base64encode(var.namespace)
  }
}

data "template_file" "config_yaml" {
  depends_on = [kubernetes_secret.config_yaml]

  template = file("${path.module}/../../modules//golang/config.yaml.tmpl")

  vars = {
    namespace = base64decode(kubernetes_secret.config_yaml.data["namespace"])
  }
}

resource "kubernetes_config_map" "cashbot_config_file" {
  metadata {
    name      = "config-yaml-map"
    namespace = var.namespace
  }

  data = {
    "config.yaml" = data.template_file.config_yaml.rendered
  }
}