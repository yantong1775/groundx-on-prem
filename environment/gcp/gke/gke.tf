locals {
  should_create = var.environment.vpc_id != "" && length(var.environment.subnets) > 0

  node_groups = merge(
    {
      cpu_memory_nodes                                      = {
        name                                                = var.cluster.nodes.cpu_memory

        machine_type                                            = var.nodes.node_groups.cpu_memory_nodes.machine_type
        image_type                                      = var.nodes.node_groups.cpu_memory_nodes.image_type

        node_count                                        = var.nodes.node_groups.cpu_memory_nodes.node_count
        max_count                                            = var.nodes.node_groups.cpu_memory_nodes.max_count
        min_count                                            = var.nodes.node_groups.cpu_memory_nodes.min_count

        disk_size_gb                                      = var.nodes.node_groups.cpu_memory_nodes.disk_size_gb
        disk_type                                         = var.nodes.node_groups.cpu_memory_nodes.disk_type
        
        accelerator_count  = 0
        accelerator_type   = ""
        gpu_driver_version = ""
        
        # tags                                                = {
        #   Environment                                       = var.environment.stage
        #   Name                                              = var.cluster.nodes.cpu_memory
        #   Terraform                                         = "true"
        #   "k8s.io/cluster-autoscaler/enabled"               = "true"
        #   "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
        # }
      },
      cpu_only_nodes                                        = {
        name                                                = var.cluster.nodes.cpu_only

        machine_type                                            = var.nodes.node_groups.cpu_only_nodes.machine_type
        image_type                                      = var.nodes.node_groups.cpu_only_nodes.image_type

        node_count                                        = var.nodes.node_groups.cpu_only_nodes.node_count
        max_count                                            = var.nodes.node_groups.cpu_only_nodes.max_count
        min_count                                            = var.nodes.node_groups.cpu_only_nodes.min_count

        disk_size_gb                                      = var.nodes.node_groups.cpu_only_nodes.disk_size_gb
        disk_type                                         = var.nodes.node_groups.cpu_only_nodes.disk_type

        accelerator_count  = 0
        accelerator_type   = ""
        gpu_driver_version = ""
        # tags                                                = {
        #   Environment                                       = var.environment.stage
        #   Name                                              = var.cluster.nodes.cpu_only
        #   Terraform                                         = "true"
        #   "k8s.io/cluster-autoscaler/enabled"               = "true"
        #   "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
        # }
      },
      gpu_layout_nodes                                      = {
        name                                                = var.cluster.nodes.gpu_layout

        machine_type                                            = var.nodes.node_groups.layout_nodes.machine_type
        image_type                                      = var.nodes.node_groups.layout_nodes.image_type

        node_count                                        = var.nodes.node_groups.layout_nodes.node_count
        max_count                                            = var.nodes.node_groups.layout_nodes.max_count
        min_count                                            = var.nodes.node_groups.layout_nodes.min_count 

        disk_size_gb                                      = var.nodes.node_groups.layout_nodes.disk_size_gb
        disk_type                                         = var.nodes.node_groups.layout_nodes.disk_type

        accelerator_count                                 = var.nodes.node_groups.layout_nodes.accelerator_count
        accelerator_type                                  = var.nodes.node_groups.layout_nodes.accelerator_type
        gpu_driver_version                                = var.nodes.node_groups.layout_nodes.gpu_driver_version

        # tags                                                = {
        #   Environment                                       = var.environment.stage
        #   Name                                              = var.cluster.nodes.gpu_layout
        #   Terraform                                         = "true"
        #   "k8s.io/cluster-autoscaler/enabled"               = "true"
        #   "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
        # }
      },
      gpu_summary_nodes                                     = {
        name                                                = var.cluster.nodes.gpu_summary

        machine_type                                            = var.nodes.node_groups.summary_nodes.machine_type
        image_type                                      = var.nodes.node_groups.summary_nodes.image_type

        node_count                                        = var.nodes.node_groups.summary_nodes.node_count
        max_count                                            = var.nodes.node_groups.summary_nodes.max_count
        min_count                                            = var.nodes.node_groups.summary_nodes.min_count

        disk_size_gb                                      = var.nodes.node_groups.summary_nodes.disk_size_gb
        disk_type                                         = var.nodes.node_groups.summary_nodes.disk_type

        accelerator_count                                 = var.nodes.node_groups.summary_nodes.accelerator_count
        accelerator_type = var.nodes.node_groups.summary_nodes.accelerator_type
        gpu_driver_version                                = var.nodes.node_groups.summary_nodes.gpu_driver_version

        # tags                                                = {
        #   Environment                                       = var.environment.stage
        #   Name                                              = var.cluster.nodes.gpu_summary
        #   Terraform                                         = "true"
        #   "k8s.io/cluster-autoscaler/enabled"               = "true"
        #   "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
        # }
      } 
    },
    var.cluster.search ? {
      gpu_ranker_nodes                                      = {
        name                                                = var.cluster.nodes.gpu_ranker

        machine_type                                            = var.nodes.node_groups.ranker_nodes.machine_type
        image_type                                      = var.nodes.node_groups.ranker_nodes.image_type

        node_count                                        = var.nodes.node_groups.ranker_nodes.node_count
        max_count                                            = var.nodes.node_groups.ranker_nodes.max_count
        min_count                                            = var.nodes.node_groups.ranker_nodes.min_count

        disk_size_gb                                      = var.nodes.node_groups.ranker_nodes.disk_size_gb
        disk_type                                         = var.nodes.node_groups.ranker_nodes.disk_type

        accelerator_count                                 = var.nodes.node_groups.ranker_nodes.accelerator_count
        accelerator_type                                  = var.nodes.node_groups.ranker_nodes.accelerator_type
        gpu_driver_version                                = var.nodes.node_groups.ranker_nodes.gpu_driver_version

        # tags                                                = {
        #   Environment                                       = var.environment.stage
        #   Name                                              = var.cluster.nodes.gpu_ranker
        #   Terraform                                         = "true"
        #   "k8s.io/cluster-autoscaler/enabled"               = "true"
        #   "k8s.io/cluster-autoscaler/${local.cluster_name}" = "owned"
        # }
      }
    } : {})
}

module "eyelevel_gke" {
  count = local.should_create ? 1 : 0

  source                                   = "terraform-google-modules/kubernetes-engine/google"
  
  project_id = var.environment.project_id
  name                                    = local.cluster_name
  region                                 = var.environment.region
  zones = var.environment.zones

  # network settings
  network = var.environment.vpc_id
  subnetwork = var.environment.subnets[0]
  ip_range_pods              = var.vpc.pods_secondary_range_name # The name of the secondary subnet ip range to use for pods
  ip_range_services          = var.vpc.services_secondary_range_name # The name of the secondary subnet range to use for services

  node_pools = values(local.node_groups)

}

resource "null_resource" "wait_for_gke" {
  count = local.should_create ? 1 : 0

  depends_on = [module.eyelevel_gke]

  # update kubeconfig for gke cluster
  # https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-access-for-kubectl
  provisioner "local-exec" {
    command  = "gcloud container clusters get-credentials ${local.cluster_name} --region ${var.environment.region}"
  }
}