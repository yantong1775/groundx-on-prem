data "template_file" "layout_config_py" {
  count = local.create_none ? 0 : 1

  template = file("${path.module}/../../../modules/layout/config.py.tpl")

  vars = {
    cacheService     = var.cache_service
    deviceType       = var.layout_models.figure.device
    fileAccessKey    = var.file_access_key
    fileAccessSecret = var.file_access_secret
    fileService      = var.file_service
    fileSSL          = var.file_ssl
    namespace        = var.namespace
    layoutModelName  = var.layout_models.figure.model
    layoutService    = var.layout_service.name
    uploadBucket     = var.file_upload_bucket
    validAPIKey      = var.admin_api_key
  }
}

resource "kubernetes_config_map" "layout_config_file" {
  count = local.create_none ? 0 : 1

  depends_on = [kubernetes_namespace.eyelevel]

  metadata {
    name      = "layout-config-py-map"
    namespace = var.namespace
  }

  data = {
    "config.py" = data.template_file.layout_config_py[0].rendered
  }
}

data "template_file" "ranker_config_py" {
  count = local.create_none ? 0 : 1

  template = file("${path.module}/../../../modules/ranker/config.py.tpl")

  vars = {
    cacheService    = var.cache_service
    deviceType      = var.ranker_inference_device
    namespace       = var.namespace
    rankerMaxBatch  = var.ranker_inference_max_batch
    rankerMaxPrompt = var.ranker_inference_max_prompt
    rankerModelName = var.ranker_inference_model
    rankerService   = var.ranker_service
    validAPIKey     = var.admin_api_key
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

data "template_file" "summary_config_py" {
  count = local.create_none ? 0 : 1

  template = file("${path.module}/../../../modules/summary/config.py.tpl")

  vars = {
    cacheService     = var.cache_service
    deviceType       = var.summary_inference_device
    namespace        = var.namespace
    summaryMaxBatch  = var.summary_inference_max_batch
    summaryMaxPrompt = var.summary_inference_max_prompt
    summaryModelName = var.summary_inference_model
    summaryService   = var.summary_service
    validAPIKey      = var.admin_api_key
  }
}

resource "kubernetes_config_map" "summary_config_file" {
  count = local.create_none ? 0 : 1

  depends_on = [kubernetes_namespace.eyelevel]

  metadata {
    name      = "summary-config-py-map"
    namespace = var.namespace
  }

  data = {
    "config.py" = data.template_file.summary_config_py[0].rendered
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
    deploymentType       = local.create_kafka == false ? "search" : "all"
    fileAccessKey        = var.file_access_key
    fileAccessSecret     = var.file_access_secret
    fileService          = var.file_service
    fileSSL              = var.file_ssl
    groundxService       = var.groundx_service
    groundxServiceKey    = var.admin_api_key
    groundxUsername      = var.admin_username
    layoutService        = var.layout_service.name
    layoutWebhookService = var.layout_webhook_service
    namespace            = var.namespace
    preProcessService    = var.pre_process_service
    processService       = var.process_service
    queueService         = var.queue_service
    rankerService        = "${var.ranker_service}-api"
    searchIndex          = var.search_index
    searchPassword       = var.search_password
    searchRootPassword   = var.search_root_password
    searchService        = "${var.search_service}-cluster-master"
    searchUser           = var.search_user
    streamService        = var.stream_service
    summaryService       = "${var.summary_service}-api"
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