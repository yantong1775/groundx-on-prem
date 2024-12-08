locals {
  config_models = templatefile("${local.module_path}/config/config_models.py.tpl", {})

  config_yaml = templatefile(
    "${local.module_path}/config/config.yaml.tpl", {
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
    engines              = jsonencode(var.engines)
    fileBaseDomain       = local.file_settings.base_domain
    filePassword         = local.file_settings.password
    fileService          = var.file_internal.service
    fileSSL              = local.file_settings.ssl
    fileUsername         = local.file_settings.username
    groundxService       = var.groundx_internal.service
    groundxServiceKey    = var.admin.api_key
    groundxUsername      = var.admin.username
    ingestOnly           = local.ingest_only
    languages            = jsonencode(var.app.languages)
    layoutService        = "${var.layout_internal.service}-api"
    layoutWebhookService = var.layout_webhook_internal.service
    namespace            = var.app_internal.namespace
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
    summaryClientThreads = var.summary_client_resources.threads
    summaryService       = var.summary_internal.service
    uploadBucket         = local.file_settings.bucket
    uploadService        = var.upload_internal.service
  })

  layout_config = templatefile(
    "${local.module_path}/layout/config.py.tpl", {
    cacheAddr        = local.cache_settings.addr
    cachePort        = local.cache_settings.port
    deviceType       = var.layout_internal.models.device
    fileBaseDomain   = local.file_settings.base_domain
    filePassword     = local.file_settings.password
    fileService      = var.file_internal.service
    fileSSL          = local.file_settings.ssl
    fileUsername     = local.file_settings.username
    namespace        = var.app_internal.namespace
    layoutService    = var.layout_internal.service
    ocrProject       = var.layout.ocr.project
    ocrType          = var.layout.ocr.type
    uploadBucket     = local.file_settings.bucket
    validAPIKey      = var.admin.api_key
    validUsername    = var.admin.username
  })

  layout_gunicorn = templatefile(
    "${local.module_path}/layout/gunicorn_conf.py.tpl", {
    threads = var.layout_resources.api.threads
    workers = var.layout_resources.api.workers
  })

  layout_ocr_data = var.layout.ocr.credentials != "" ? file("${path.module}/../../../${var.layout.ocr.credentials}") : ""

  layout_supervisord = "${
    file(
      "${local.module_path}/layout/supervisord.base.conf.tpl"
    )
  }\n${
    join(
      "\n",
      [
        for i in range(var.layout_resources.inference.workers) : templatefile("${local.module_path}/layout/supervisord.conf.tpl", {
          worker_number = i + 1
        })
      ]
    )
  }"

  ranker_config = templatefile(
    "${local.module_path}/ranker/config.py.tpl", {
    cacheAddr       = local.cache_settings.addr
    cachePort       = local.cache_settings.port
    deviceType      = var.ranker_internal.inference.device
    rankerService   = var.ranker_internal.service
    validAPIKey     = var.admin.api_key
    validUsername   = var.admin.username
  })

  ranker_gunicorn = templatefile(
    "${local.module_path}/ranker/gunicorn_conf.py.tpl", {
    threads = var.ranker_resources.api.threads
    workers = var.ranker_resources.api.workers
  })

  ranker_supervisord = "${
    file(
      "${local.module_path}/ranker/supervisord.base.conf.tpl"
    )
  }\n${
    join(
      "\n",
      [
        for i in range(var.ranker_resources.inference.workers) : templatefile("${local.module_path}/ranker/supervisord.conf.tpl", {
          worker_number = i + 1
        })
      ]
    )
  }"

  summary_config = templatefile(
    "${local.module_path}/summary/config.py.tpl", {
    cacheAddr        = local.cache_settings.addr
    cachePort        = local.cache_settings.port
    defaultLimit     = var.summary_resources.inference.replicas * var.summary_resources.inference.workers
    deviceType       = var.summary_internal.inference.device
    summaryService   = var.summary_internal.service
    validAPIKey      = var.admin.api_key
    validUsername    = var.admin.username
  })

  summary_gunicorn = templatefile(
    "${local.module_path}/summary/gunicorn_conf.py.tpl", {
    threads = var.summary_resources.api.threads
    workers = var.summary_resources.api.workers
  })

  summary_supervisord = "${
    file(
      "${local.module_path}/summary/supervisord.base.conf.tpl"
    )
  }\n${
    join(
      "\n",
      [
        for i in range(var.summary_resources.inference.workers) : templatefile("${local.module_path}/summary/supervisord.conf.tpl", {
          worker_number = i + 1
          threads       = var.summary_resources.inference.threads
        })
      ]
    )
  }"
}

resource "kubernetes_config_map" "cashbot_config_file" {
  metadata {
    name      = "config-yaml-map"
    namespace = var.app_internal.namespace
  }

  data = {
    "config.yaml" = local.config_yaml
  }
}

resource "kubernetes_config_map" "config_models" {
  metadata {
    name      = "config-models-map"
    namespace = var.app_internal.namespace
  }

  data = {
    "config_models.py" = local.config_models
  }
}

resource "kubernetes_config_map" "layout_config_file" {
  metadata {
    name      = "layout-config-py-map"
    namespace = var.app_internal.namespace
  }

  data = {
    "config.py" = local.layout_config
  }
}

resource "kubernetes_config_map" "layout_gunicorn_conf_file" {
  metadata {
    name      = "layout-gunicorn-conf-py-map"
    namespace = var.app_internal.namespace
  }

  data = {
    "gunicorn_conf.py" = local.layout_gunicorn
  }
}

resource "kubernetes_config_map" "layout_ocr_credentials" {
  metadata {
    name      = "layout-ocr-credentials-map"
    namespace = var.app_internal.namespace
  }

  data = {
    "credentials.json" = local.layout_ocr_data
  }
}

resource "kubernetes_config_map" "layout_supervisord_16gb_conf" {
  metadata {
    name      = "layout-supervisord-16gb-conf-map"
    namespace = var.app_internal.namespace
  }

  data = {
    "supervisord.conf" = local.layout_supervisord
  }
}

resource "kubernetes_config_map" "ranker_gunicorn_conf_file" {
  metadata {
    name      = "ranker-gunicorn-conf-py-map"
    namespace = var.app_internal.namespace
  }

  data = {
    "gunicorn_conf.py" = local.ranker_gunicorn
  }
}

resource "kubernetes_config_map" "ranker_config_file" {
  metadata {
    name      = "ranker-config-py-map"
    namespace = var.app_internal.namespace
  }

  data = {
    "config.py" = local.ranker_config
  }
}

resource "kubernetes_config_map" "ranker_supervisord_16gb_conf" {
  metadata {
    name      = "ranker-supervisord-16gb-conf-map"
    namespace = var.app_internal.namespace
  }

  data = {
    "supervisord.conf" = local.ranker_supervisord
  }
}

resource "kubernetes_config_map" "summary_config_file" {
  metadata {
    name      = "summary-config-py-map"
    namespace = var.app_internal.namespace
  }

  data = {
    "config.py" = local.summary_config
  }
}

resource "kubernetes_config_map" "summary_gunicorn_conf_file" {
  metadata {
    name      = "summary-gunicorn-conf-py-map"
    namespace = var.app_internal.namespace
  }

  data = {
    "gunicorn_conf.py" = local.summary_gunicorn
  }
}

resource "kubernetes_config_map" "summary_supervisord_24gb_conf" {
  metadata {
    name      = "summary-supervisord-24gb-conf-map"
    namespace = var.app_internal.namespace
  }

  data = {
    "supervisord.conf" = local.summary_supervisord
  }
}