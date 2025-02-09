resource "google_compute_network" "vpc" {
  name                    = "${local.cluster_name}-vpc"
  project                 = var.environment.project_id
  routing_mode = "GLOBAL"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke-subnet" {
  name          = "gke-subnet"
  project       = var.environment.project_id
  region        = var.environment.region
  network       = google_compute_network.vpc.self_link
  ip_cidr_range = "10.0.0.0/24"

  secondary_ip_range {
    range_name    = "gke-pods-range"
    ip_cidr_range = "10.1.0.0/20"  # Range for Pods (4096 addresses)
  }

  secondary_ip_range {
    range_name    = "gke-services-range"
    ip_cidr_range = "10.1.16.0/20" # Range for Services (4096 addresses)
  }
}

resource "google_compute_firewall" "allow-ssh-only-ingress" {
  name    = "allow-ssh-only"
  network = google_compute_network.vpc.self_link
  description = "Allow SSH from vpc subnets"
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_firewall" "allow-all-egress" {
  name    = "allow-all-egress"
  network = google_compute_network.vpc.self_link
  description = "Allow all traffic"
  direction = "EGRESS"

  allow {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
}