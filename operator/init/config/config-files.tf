data "template_file" "config_yaml" {
  template = file("${local.module_path}/golang/config.yaml.tpl")

  vars = {
    cacheNotCluster      = var.cache_internal.is_instance
    cacheService         = var.cache_internal.service
    dashboardService     = var.dashboard_internal.service
    dbName               = var.db_internal.db_name
    dbPassword           = var.db.db_password
    dbRootPassword       = var.db.db_root_password
    dbService            = "${var.db_internal.service}-cluster-pxc-haproxy"
    dbUser               = var.db_internal.db_username
    deploymentType       = var.groundx_internal.type
    fileAccessKey        = var.file.access_key
    fileAccessSecret     = var.file.access_secret
    fileService          = var.file_internal.service
    fileSSL              = var.file.ssl
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
    searchIndex          = var.search_internal.index
    searchPassword       = var.search.password
    searchRootPassword   = var.search.root_password
    searchService        = "${var.search_internal.service}-cluster-master"
    searchUser           = var.search_internal.user
    streamService        = var.stream_internal.service
    summaryService       = "${var.summary_internal.service}-api"
    uploadBucket         = var.file_internal.upload_bucket
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
    cacheService     = var.cache_internal.service
    deviceType       = var.layout_internal.models.device
    figureModel      = var.layout_internal.models.figure.name
    figureModelPth   = var.layout_internal.models.figure.pth
    figureModelYml   = var.layout_internal.models.figure.yml
    fileAccessKey    = var.file.access_key
    fileAccessSecret = var.file.access_secret
    fileService      = var.file_internal.service
    fileSSL          = var.file.ssl ? "True" : "False"
    namespace        = var.app.namespace
    layoutService    = var.layout_internal.service
    ocrProject       = var.layout_ocr.project
    ocrType          = var.layout_ocr.type
    tableModel       = var.layout_internal.models.table.name
    tableModelPth    = var.layout_internal.models.table.pth
    tableModelYml    = var.layout_internal.models.table.yml
    uploadBucket     = var.file_internal.upload_bucket
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
  count = var.layout_ocr.credentials == "" || var.layout_ocr.type != "google" ? 0 : 1

  metadata {
    name      = "layout-ocr-credentials-map"
    namespace = var.app.namespace
  }

  data = {
    "credentials.json" = file("${path.module}/../../../${var.layout_ocr.credentials}")
  }
}

data "template_file" "layout_supervisord_16gb_workers" {
  count = var.layout_internal.resources.workers

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
    cacheService    = var.cache_internal.service
    deviceType      = var.ranker_internal.inference.device
    namespace       = var.app.namespace
    rankerMaxBatch  = var.ranker_internal.inference.max_batch
    rankerMaxPrompt = var.ranker_internal.inference.max_prompt
    rankerModelName = var.ranker_internal.inference.model
    rankerService   = var.ranker_internal.service
    validAPIKey      = var.admin.api_key
    validUsername    = var.admin.username
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
  count = var.ranker_internal.resources.workers

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
    cacheService     = var.cache_internal.service
    deviceType       = var.summary_internal.inference.device
    namespace        = var.app.namespace
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
  count = var.summary_internal.resources.workers

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