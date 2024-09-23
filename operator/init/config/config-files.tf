data "template_file" "config_yaml" {
  template = file("${local.module_path}/golang/config.yaml.tpl")

  vars = {
    cacheAddr            = local.cache_settings.addr
    cacheNotCluster      = local.cache_settings.is_instance
    cachePort            = local.cache_settings.port
    dashboardService     = var.dashboard_internal.service
    dbName               = var.db.db_name
    dbPassword           = var.db.db_password
    dbRootPassword       = var.db.db_root_password
    dbRO                 = local.db_endpoints.ro
    dbRW                 = local.db_endpoints.rw
    dbUser               = var.db.db_username
    deploymentType       = var.groundx_internal.type
    fileBaseDomain       = local.file_settings.base_domain
    filePassword         = local.file_settings.password
    fileService          = var.file_internal.service
    fileSSL              = local.file_settings.ssl
    fileUsername         = local.file_settings.username
    groundxService       = var.groundx_internal.service
    groundxServiceKey    = var.admin.api_key
    groundxUsername      = var.admin.username
    layoutService        = "${var.layout_internal.service}-api"
    layoutWebhookService = var.layout_webhook_internal.service
    namespace            = var.app.namespace
    preProcessService    = var.pre_process_internal.service
    processService       = var.process_internal.service
    queueService         = var.queue_internal.service
    rankerService        = "${var.ranker_internal.service}-api"
    searchBaseUrl        = local.search_settings.base_url
    searchIndex          = var.search.index
    searchPassword       = var.search.password
    searchRootPassword   = var.search.root_password
    searchUser           = var.search.user
    streamBaseUrl        = "${local.stream_settings.base_domain}:${local.stream_settings.port}"
    summaryApiKey        = local.summary_credentials.api_key
    summaryBaseUrl       = local.summary_credentials.base_url
    summaryService       = var.summary_internal.service
    uploadBucket         = local.file_settings.bucket
    uploadService        = var.upload_internal.service
  }
}

resource "kubernetes_config_map" "cashbot_config_file" {
  metadata {
    name      = "config-yaml-map"
    namespace = var.app.namespace
  }

  data = {
    "config.yaml" = data.template_file.config_yaml.rendered
  }
}

data "template_file" "layout_config_py" {
  template = file("${local.module_path}/layout/config.py.tpl")

  vars = {
    cacheAddr        = local.cache_settings.addr
    cachePort        = local.cache_settings.port
    deviceType       = var.layout_internal.models.device
    figureModel      = var.layout_internal.models.figure.name
    figureModelPth   = var.layout_internal.models.figure.pth
    figureModelYml   = var.layout_internal.models.figure.yml
    fileBaseDomain   = local.file_settings.base_domain
    filePassword     = local.file_settings.password
    fileService      = var.file_internal.service
    fileSSL          = local.file_settings.ssl
    fileUsername     = local.file_settings.username
    namespace        = var.app.namespace
    layoutService    = var.layout_internal.service
    ocrProject       = var.layout.ocr.project
    ocrType          = var.layout.ocr.type
    tableModel       = var.layout_internal.models.table.name
    tableModelPth    = var.layout_internal.models.table.pth
    tableModelYml    = var.layout_internal.models.table.yml
    uploadBucket     = local.file_settings.bucket
    validAPIKey      = var.admin.api_key
    validUsername    = var.admin.username
  }
}

resource "kubernetes_config_map" "layout_config_file" {
  metadata {
    name      = "layout-config-py-map"
    namespace = var.app.namespace
  }

  data = {
    "config.py" = data.template_file.layout_config_py.rendered
  }
}

resource "kubernetes_config_map" "layout_ocr_credentials" {
  count = var.layout.ocr.credentials == "" || var.layout.ocr.type != "google" ? 0 : 1

  metadata {
    name      = "layout-ocr-credentials-map"
    namespace = var.app.namespace
  }

  data = {
    "credentials.json" = file("${path.module}/../../../${var.layout.ocr.credentials}")
  }
}

data "template_file" "layout_supervisord_16gb_workers" {
  count = var.layout_resources.inference.workers

  template = file("${local.module_path}/layout/supervisord.conf.tpl")

  vars = {
    worker_number = count.index + 1
  }
}

data "template_file" "layout_supervisord_16gb_conf_template" {
  template = "${file("${local.module_path}/layout/supervisord.base.conf.tpl")}\n${join("\n", data.template_file.layout_supervisord_16gb_workers[*].rendered)}"
}

resource "kubernetes_config_map" "layout_supervisord_16gb_conf" {
  metadata {
    name      = "layout-supervisord-16gb-conf-map"
    namespace = var.app.namespace
  }

  data = {
    "supervisord.conf" = data.template_file.layout_supervisord_16gb_conf_template.rendered
  }
}

data "template_file" "ranker_config_py" {
  template = file("${local.module_path}/ranker/config.py.tpl")

  vars = {
    cacheAddr       = local.cache_settings.addr
    cachePort       = local.cache_settings.port
    deviceType      = var.ranker_internal.inference.device
    rankerMaxBatch  = var.ranker_internal.inference.max_batch
    rankerMaxPrompt = var.ranker_internal.inference.max_prompt
    rankerModelName = var.ranker_internal.inference.model
    rankerService   = var.ranker_internal.service
    validAPIKey     = var.admin.api_key
    validUsername   = var.admin.username
  }
}

resource "kubernetes_config_map" "ranker_config_file" {
  metadata {
    name      = "ranker-config-py-map"
    namespace = var.app.namespace
  }

  data = {
    "config.py" = data.template_file.ranker_config_py.rendered
  }
}

data "template_file" "ranker_supervisord_16gb_workers" {
  count = var.ranker_resources.inference.workers

  template = file("${local.module_path}/ranker/supervisord.conf.tpl")

  vars = {
    worker_number = count.index + 1
  }
}

data "template_file" "ranker_supervisord_16gb_conf_template" {
  template = "${file("${local.module_path}/ranker/supervisord.base.conf.tpl")}\n${join("\n", data.template_file.ranker_supervisord_16gb_workers[*].rendered)}"
}

resource "kubernetes_config_map" "ranker_supervisord_16gb_conf" {
  metadata {
    name      = "ranker-supervisord-16gb-conf-map"
    namespace = var.app.namespace
  }

  data = {
    "supervisord.conf" = data.template_file.ranker_supervisord_16gb_conf_template.rendered
  }
}

data "template_file" "summary_config_py" {
  template = file("${local.module_path}/summary/config.py.tpl")

  vars = {
    cacheAddr        = local.cache_settings.addr
    cachePort        = local.cache_settings.port
    deviceType       = var.summary_internal.inference.device
    summaryMaxBatch  = var.summary_internal.inference.max_batch
    summaryMaxPrompt = var.summary_internal.inference.max_prompt
    summaryModelName = var.summary_internal.inference.model
    summaryService   = var.summary_internal.service
    validAPIKey      = var.admin.api_key
    validUsername    = var.admin.username
  }
}

resource "kubernetes_config_map" "summary_config_file" {
  metadata {
    name      = "summary-config-py-map"
    namespace = var.app.namespace
  }

  data = {
    "config.py" = data.template_file.summary_config_py.rendered
  }
}

data "template_file" "summary_supervisord_24gb_workers" {
  count = var.summary_resources.inference.workers

  template = file("${local.module_path}/summary/supervisord.conf.tpl")

  vars = {
    worker_number = count.index + 1
  }
}

data "template_file" "summary_supervisord_24gb_conf_template" {
  template = "${file("${local.module_path}/summary/supervisord.base.conf.tpl")}\n${join("\n", data.template_file.summary_supervisord_24gb_workers[*].rendered)}"
}

resource "kubernetes_config_map" "summary_supervisord_24gb_conf" {
  metadata {
    name      = "summary-supervisord-24gb-conf-map"
    namespace = var.app.namespace
  }

  data = {
    "supervisord.conf" = data.template_file.summary_supervisord_24gb_conf_template.rendered
  }
}