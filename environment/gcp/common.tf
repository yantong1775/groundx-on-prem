# google_client_config and kubernetes provider must be explicitly specified like the following.
data "google_client_config" "default" {}

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

# provider "aws" {
#   region = var.environment.region
# }

provider "random" {}

resource "random_string" "name_suffix" {
  length  = 6
  special = false
  upper   = false
  lower   = true
}

locals {
  cluster_name = "${var.cluster.prefix}_${random_string.name_suffix.result}"
}