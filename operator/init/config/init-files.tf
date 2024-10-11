data "template_file" "init_database" {
  template = file("${local.module_path}/mysql/init-db.sql")

  vars = {
    dbUserAPIKey = var.admin.api_key
    dbUserEmail  = var.admin.email
    dbUsername   = var.admin.username
    searchIndex  = var.search.index
  }
}

resource "kubernetes_config_map" "init_database_file" {
  metadata {
    name      = "init-database-file"
    namespace = var.app_internal.namespace
  }

  data = {
    "init-db.sql" = data.template_file.init_database.rendered
  }
}