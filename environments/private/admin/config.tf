data "template_file" "ranker_config_py" {
  count = local.create_none ? 0 : 1

  template = file("${path.module}/../../../modules/python/ranker.config.py.tpl")

  vars = {
    cacheService    = var.cache_service
    deviceType      = var.ranker_inference_device
    namespace       = var.namespace
    rankerMaxBatch  = var.ranker_inference_max_batch
    rankerMaxPrompt = var.ranker_inference_max_prompt
    rankerModelName = var.ranker_inference_model
    rankerService   = var.ranker_service
    validAPIKey     = var.groundx_service_key
  }
}

resource "kubernetes_config_map" "ranker_config_file" {
  count = local.create_none ? 0 : 1

  depends_on = [kubernetes_namespace.eyelevel]

  metadata {
    name      = "ranker-config-py-map"
    namespace = var.namespace
  }

  data = {
    "config.py" = data.template_file.ranker_config_py[0].rendered
  }
}

data "template_file" "config_yaml" {
  count = local.create_none ? 0 : 1

  template = file("${path.module}/../../../modules/golang/config.yaml.tpl")

  vars = {
    cacheNotCluster      = var.cache_is_instance
    cacheService         = var.cache_service
    dashboardService     = var.dashboard_service
    dbName               = var.db_name
    dbPassword           = var.db_password
    dbRootPassword       = var.db_root_password
    dbService            = "${var.db_service}-cluster-pxc-db-haproxy"
    dbUser               = var.db_username
    fileAccessKey        = var.file_access_key
    fileAccessSecret     = var.file_access_secret
    fileService          = var.file_service
    groundxService       = var.groundx_service
    groundxServiceKey    = var.groundx_service_key
    groundxUsername      = var.groundx_username
    layoutService        = var.layout_service
    layoutWebhookService = var.layout_webhook_service
    namespace            = var.namespace
    queueService         = var.queue_service
    preProcessService    = var.preprocess_service
    processService       = var.process_service
    rankerService        = var.ranker_service
    searchIndex          = var.search_index
    searchPassword       = var.search_password
    searchService        = var.search_service
    searchUser           = var.search_user
    streamService        = var.stream_service
    summaryService       = var.summary_service
    uploadService        = var.upload_service
  }
}

resource "kubernetes_config_map" "cashbot_config_file" {
  count = local.create_none ? 0 : 1

  depends_on = [kubernetes_namespace.eyelevel]

  metadata {
    name      = "config-yaml-map"
    namespace = var.namespace
  }

  data = {
    "config.yaml" = data.template_file.config_yaml[0].rendered
  }
}