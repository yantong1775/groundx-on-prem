module "eyelevel_vpc" {
  source  = "terraform-google-modules/network/google"

  project_id             = var.environment.project_id
  network_name           = "${local.cluster_name}-vpc"
  routing_mode           = "GLOBAL"
  auto_create_subnetworks = false

  subnets = [
    {
      subnet_name  = "gke-subnet"
      subnet_ip = "10.0.0.0/24"
      subnet_region = var.environment.region
    }
  ]

  secondary_ranges = {
    gke-subnet = [
      {
        range_name    = "gke-pods-range"
        ip_cidr_range = "10.1.0.0/20"   # IP range for Pods
      },
      {
        range_name   = "gke-services-range"
        ip_cidr_range = "10.1.16.0/20"   # IP range for Services
      }
    ]
  }

  ingress_rules = {
    name = "allow_ssh_vpc_only"
    description = "firewall ingress rule to allow ssh from vpc subnets only"
  
    allow = [
      {
        protocol = "tcp"
        ports    = ["22"]
      }
    ]
  }

  egress_rules = {
    name = "allow_all"
    description = "firewall egress rule to allow all traffic"
  
    allow = [
      {
        protocol = "all"
        ports    = ["0.0.0.0/0"]
      }
    ]
  }
}