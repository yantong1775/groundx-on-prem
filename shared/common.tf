provider "kubernetes" {
  config_path = var.cluster.kube_config_path
}

locals {
  baseline_ingest = var.throughput.ingest.baseline
  baseline_search = var.throughput.search.baseline

  max_ingest = var.throughput.ingest.max
  max_search = var.throughput.search.max

  replicas = {
    cache = {
      max = var.cache_resources.replicas
      min = var.cache_resources.replicas
      node = var.cache_resources.node
      resources = var.cache_resources.resources
    }
    db = {
      operator = {
        max = var.db_resources.replicas
        min = var.db_resources.replicas
        node = var.db_resources.node
        resources = var.db_resources.resources
      }
      proxy = {
        max = var.db_resources.proxy.replicas
        min = var.db_resources.proxy.replicas
        node = var.db_resources.proxy.node
        resources = var.db_resources.proxy.resources
      }
    }
    file = {
      max = var.file_resources.pool_servers
      min = var.file_resources.pool_servers
      node = var.file_resources.node
      resources = var.file_resources.resources
    }
    groundx = {
      max = max(3, ceil(local.max_ingest / var.groundx_resources.throughput))
      min = max(1, ceil(local.baseline_ingest / var.groundx_resources.throughput))
      node = var.groundx_resources.node
      resources = var.groundx_resources.resources
    }
    layout = {
      api = {
        max = max(3, ceil(local.max_ingest / var.layout_resources.api.throughput))
        min = max(1, ceil(local.baseline_ingest / var.layout_resources.api.throughput))
        node = var.layout_resources.api.node
        resources = var.layout_resources.api.resources
      }
      inference = {
        max = max(3, ceil(local.max_ingest / var.layout_resources.inference.throughput))
        min = max(1, ceil(local.baseline_ingest / var.layout_resources.inference.throughput))
        node = var.layout_resources.inference.node
        resources = var.layout_resources.inference.resources
      }
      map = {
        max = max(3, ceil(local.max_ingest / var.layout_resources.map.throughput))
        min = max(1, ceil(local.baseline_ingest / var.layout_resources.map.throughput))
        node = var.layout_resources.map.node
        resources = var.layout_resources.map.resources
      }
      ocr = {
        max = max(3, ceil(local.max_ingest / var.layout_resources.ocr.throughput))
        min = max(1, ceil(local.baseline_ingest / var.layout_resources.ocr.throughput))
        node = var.layout_resources.ocr.node
        resources = var.layout_resources.ocr.resources
      }
      process = {
        max = max(3, ceil(local.max_ingest / var.layout_resources.process.throughput))
        min = max(1, ceil(local.baseline_ingest / var.layout_resources.process.throughput))
        node = var.layout_resources.process.node
        resources = var.layout_resources.process.resources
      }
      save = {
        max = max(3, ceil(local.max_ingest / var.layout_resources.save.throughput))
        min = max(1, ceil(local.baseline_ingest / var.layout_resources.save.throughput))
        node = var.layout_resources.save.node
        resources = var.layout_resources.save.resources
      }
    }
    layout_webhook = {
      max = max(3, ceil(local.max_ingest / var.layout_webhook_resources.throughput))
      min = max(1, ceil(local.baseline_ingest / var.layout_webhook_resources.throughput))
      node = var.layout_webhook_resources.node
      resources = var.layout_webhook_resources.resources
    }
    pre_process = {
      max = max(3, ceil(local.max_ingest / var.pre_process_resources.throughput))
      min = max(1, ceil(local.baseline_ingest / var.pre_process_resources.throughput))
      node = var.pre_process_resources.node
      resources = var.pre_process_resources.resources
    }
    process = {
      max = max(3, ceil(local.max_ingest / var.process_resources.throughput))
      min = max(1, ceil(local.baseline_ingest / var.process_resources.throughput))
      node = var.process_resources.node
      resources = var.process_resources.resources
    }
    queue = {
      max = max(3, ceil(local.max_ingest / var.queue_resources.throughput))
      min = max(1, ceil(local.baseline_ingest / var.queue_resources.throughput))
      node = var.queue_resources.node
      resources = var.queue_resources.resources
    }
    ranker = {
      api = {
        max = max(3, ceil(local.max_search / var.ranker_resources.api.throughput))
        min = max(1, ceil(local.baseline_search / var.ranker_resources.api.throughput))
        node = var.ranker_resources.api.node
        resources = var.ranker_resources.api.resources
      }
      inference = {
        max = max(3, ceil(local.max_search / var.ranker_resources.inference.throughput))
        min = max(1, ceil(local.baseline_search / var.ranker_resources.inference.throughput))
        node = var.ranker_resources.inference.node
        resources = var.ranker_resources.inference.resources
      }
    }
    search = {
      max = var.search_resources.replicas
      min = var.search_resources.replicas
      node = var.search_resources.node
      resources = var.search_resources.resources
    }
    stream = {
      max = var.stream_resources.service.replicas
      min = var.stream_resources.service.replicas
      node = var.stream_resources.node
      resources = var.stream_resources.resources
    }
    summary = {
      api = {
        max = max(3, ceil(local.max_ingest / var.summary_resources.api.throughput))
        min = max(1, ceil(local.baseline_ingest / var.summary_resources.api.throughput))
        node = var.summary_resources.api.node
        resources = var.summary_resources.api.resources
      }
      inference = {
        max = max(3, ceil(local.max_ingest / var.summary_resources.inference.throughput))
        min = max(1, ceil(local.baseline_ingest / var.summary_resources.inference.throughput))
        node = var.summary_resources.inference.node
        resources = var.summary_resources.inference.resources
      }
    }
    summary_client = {
      max = max(3, ceil(local.max_ingest / var.summary_client_resources.throughput))
      min = max(1, ceil(local.baseline_ingest / var.summary_client_resources.throughput))
      node = var.summary_client_resources.node
      resources = var.summary_client_resources.resources
    }
    upload = {
      max = max(3, ceil(local.max_ingest / var.upload_resources.throughput))
      min = max(1, ceil(local.baseline_ingest / var.upload_resources.throughput))
      node = var.upload_resources.node
      resources = var.upload_resources.resources
    }
  }
}