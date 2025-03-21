# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}
provider "google" {
  project = var.environment.project_id
  region  = var.environment.region
}

provider "kubernetes" {
  config_path = var.cluster.kube_config_path

  host                   = "https://${module.eyelevel_gke[0].endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.eyelevel_gke[0].ca_certificate)
}


provider "random" {}

resource "random_string" "name_suffix" {
  length  = 6
  special = false
  upper   = false
  lower   = true
}

locals {
  cluster_name = "${var.cluster.prefix}-${random_string.name_suffix.result}"
}