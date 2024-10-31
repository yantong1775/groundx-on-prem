provider "kubernetes" {
  config_path = var.cluster.kube_config_path
}

provider "aws" {
  region = var.environment.region
}