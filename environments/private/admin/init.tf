data "template_file" "init_database" {
  count = local.create_none ? 0 : 1

  template = file("${path.module}/../../../modules/mysql/init-db.sql")

  vars = {
    dbUserAPIKey = var.admin_api_key
    dbUserEmail  = var.admin_email
    dbUsername   = var.admin_username
    searchIndex  = var.search_index
  }
}

resource "kubernetes_config_map" "init_database_file" {
  count = local.create_none ? 0 : 1

  depends_on = [kubernetes_namespace.eyelevel]

  metadata {
    name      = "init-database-file"
    namespace = var.namespace
  }

  data = {
    "init-db.sql" = data.template_file.init_database[0].rendered
  }
}