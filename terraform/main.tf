terraform {
  # terraform version
  required_version = "~>0.12.0"
}

provider "google" {
  # provider version
  version = "2.15"
  project = var.project
  region  = var.region
}

resource "google_compute_instance" "app" {
  count        = var.reddit_instances_count
  name         = "reddit-app-${count.index}"
  machine_type = "g1-small"
  zone         = var.vm_zone
  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}\nappuser1:${file(var.public_key_path)}\nappuser2:${file(var.public_key_path)}",
  }
  tags = ["reddit-app"]

  boot_disk {
    initialize_params {
      image = var.disk_image
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.app_ip.address
    }
  }

  connection {
    type        = "ssh"
    host        = self.network_interface[0].access_config[0].nat_ip
    user        = "appuser"
    agent       = false
    private_key = file(var.private_key_path)
  }

  # order of provisioners is important. Provisioners will be applied at the same order it specified in this file
  provisioner "file" {
    source      = "files/puma.service"
    destination = "/tmp/puma.service"
  }

  provisioner "remote-exec" {
    script = "files/deploy.sh"
  }
}

resource "google_compute_firewall" "firewall_puma" {
  name = "allow-puma-default"
  # network to be used to apply rule
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["9292"]
  }
  # addresses range to allow access
  source_ranges = ["0.0.0.0/0"]
  # this firewall rule will be applicable for instances with the tags listed in "target_tags"
  target_tags = ["reddit-app"]
}

resource "google_compute_firewall" "firewall_ssh" {
  name        = "default-allow-ssh"
  description = "TF: Allow SSH from anywhere"
  network     = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}
