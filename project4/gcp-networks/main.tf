// Terarform bckend
terraform {
  backend "gcs" {
    bucket = "git-terraform-101"
    prefix = "gcp-lab-01"
    credentials = "credential.json"
  }
}
provider "google" {
  project     = var.project_name
  credentials = "credential.json"
}
resource "google_compute_network" "vpc_network" {
  name = var.vpc_name
  auto_create_subnetworks = false
  project = var.project_name
}
resource "google_compute_subnetwork" "subnet-1" {
  name          = "lab-app-subnet"
  ip_cidr_range = "172.16.10.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
  secondary_ip_range {
    range_name    = "k8s-pods"
    ip_cidr_range = "172.16.60.0/24"
  }
  /*secondary_ip_range {
    range_name    = "k8s-services"
    ip_cidr_range = "172.16.20.0/24"
  }*/
}
resource "google_compute_subnetwork" "subnet-2" {
  name          = "lab-web-subnet"
  ip_cidr_range = "172.16.30.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}
resource "google_compute_firewall" "allow-ssh" {
  name    = "lab-allow-ssh"
  project = var.project_name
  network = google_compute_network.vpc_network.id
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}
resource "google_compute_firewall" "allow-internal" {
  name    = "lab-allow-internal"
  project = var.project_name
  network = google_compute_network.vpc_network.id
  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }
  allow {
  protocol = "udp"
    ports    = ["1-65535"]
  }
   allow {
  protocol = "icmp"
  }
  source_ranges = ["172.16.0.0/24", "172.16.10.0/24", "172.16.20.0/24", "172.16.30.0/24" ]
}