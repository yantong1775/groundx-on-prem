locals {
  node_assignment = {
    cache             = var.cluster.nodes.cpu_memory
    db                = var.cluster.nodes.cpu_memory
    file              = var.cluster.nodes.cpu_memory
    graph             = var.cluster.nodes.cpu_memory
    groundx           = var.cluster.nodes.cpu_only
    layout_api        = var.cluster.nodes.cpu_only
    layout_inference  = var.cluster.nodes.gpu_layout
    layout_map        = var.cluster.nodes.cpu_only
    layout_ocr        = var.cluster.nodes.cpu_memory
    layout_process    = var.cluster.nodes.cpu_only
    layout_save       = var.cluster.nodes.cpu_only
    layout_webhook    = var.cluster.nodes.cpu_only
    metrics           = var.cluster.nodes.cpu_only
    pre_process       = var.cluster.nodes.cpu_memory
    process           = var.cluster.nodes.cpu_only
    queue             = var.cluster.nodes.cpu_only
    ranker_api        = var.cluster.nodes.cpu_only
    ranker_inference  = var.cluster.nodes.gpu_ranker
    summary_api       = var.cluster.nodes.cpu_only
    summary_inference = var.cluster.nodes.gpu_summary
    summary_client    = var.cluster.nodes.cpu_only
    search            = var.cluster.nodes.cpu_memory
    stream            = var.cluster.nodes.cpu_memory
    upload            = var.cluster.nodes.cpu_only
  }
}