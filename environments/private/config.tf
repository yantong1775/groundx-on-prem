data "template_file" "config_yaml" {
  count = local.create_none ? 0 : 1

  depends_on = [kubernetes_namespace.eyelevel]

  template = file("${path.module}/../../modules//golang/config.yaml.tmpl")

  vars = {
    cacheService = var.cache_service
    dashboardService = var.dashboard_service
    dbName = var.db_name
    dbNotCluster = var.db_ip_type != "ClusterIP"
    dbPassword = var.db_password
    dbService = var.db_service
    dbUser = var.db_username
    fileService = var.file_service
    groundxService = var.groundx_service
    groundxServiceKey = var.groundx_service_key
    groundxUsername = var.groundx_username
    layoutService = var.layout_service
    layoutWebhookService = var.layout_webhook_service
    namespace = var.namespace
    queueService = var.queue_service
    preProcessService = var.preprocess_service
    processService = var.process_service
    rankerService = var.ranker_service
    searchIndex = var.search_index
    searchPassword = var.search_password
    searchService = var.search_service
    searchUser = var.search_user
    summaryService = var.summary_service
    uploadService = var.upload_service
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