# Setting Google as provider for required plugin download
terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  project = "alpha-finance-app" # Sets alpha-finance-app as the GCP project for resources provisioning
  region  = "us-central1"
  zone    = "us-central1-a"
}

# Creates VPC network for the VM instance
resource "google_compute_network" "vpc_network" {
  name = "alpha-finance-app"
  auto_create_subnetworks = true
  mtu = 1460
}

# Creates a Firewall Rule in the VPC network to allow SSH connection to the VM instance
resource "google_compute_firewall" "SSH" {
  name = "alpha-finance-app-allow-ssh"

  allow {
    ports = ["22"]
    protocol = "tcp"
  }

  direction = "INGRESS"
  network = google_compute_network.vpc_network.id
  priority = 1000
  source_ranges = ["0.0.0.0/0"]
}

# Creates a Firewall Rule in the VPC network to allow ingress connection (Web and MongoDb)
resource "google_compute_firewall" "fw_ingress" {
  name = "alpha-finance-app-fw-rule"

  allow {
    ports = ["3000", "4000", "27017"]
    protocol = "tcp"
  }

  direction = "INGRESS"
  network = google_compute_network.vpc_network.id
  priority = 1000
  source_ranges = ["0.0.0.0/0"]
}

# Creates a Firewall Rule in the VPC network to allow egress connection (Web and MongoDb)
resource "google_compute_firewall" "fw_egress" {
  name = "alpha-finance-app-fw-egress"

  allow {
    ports = ["3000", "4000", "27017"]
    protocol = "tcp"
  }

  direction = "EGRESS"
  network = google_compute_network.vpc_network.id
  priority = 1000
  source_ranges = ["0.0.0.0/0"]
}

# Creates the VM instance within the alpha-finance-app VPC network
resource "google_compute_instance" "vm_instance" {
  name = "finance-app-server"
  machine_type = "n1-standard-4"
  zone = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  metadata_startup_script = "sudo apt-get update;" # Updates the OS after launching VM

  network_interface {
    network = google_compute_network.vpc_network.id

    access_config {
      # Included for an external ip address for the VM instance
    }
  }
  
}