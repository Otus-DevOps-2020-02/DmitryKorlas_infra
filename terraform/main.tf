terraform {
  # terraform version
  required_version = "~>0.12.0"
}

provider "google" {
  # provider version
  version = "2.15"
  project = "infra-271514"
  region = "europe-west-1"
}

resource "google_compute_instance" "app" {
  name = "reddit-app"
  machine_type = "g1-small"
  zone = "europe-west1-b"
  metadata = {
	ssh-keys = "appuser:${file("~/.ssh/appuser.pub")}"
  }
  tags = ["reddit-app"]

  boot_disk {
	initialize_params {
	  image = "reddit-base"
	}
  }

  network_interface {
	network = "default"
	access_config {}
  }

  connection {
	type = "ssh"
	host = self.network_interface[0].access_config[0].nat_ip
	user = "appuser"
	agent = false
	private_key = file("~/.ssh/appuser")
  }

  # order of provisioners is important. Provisioners will be applied at the same order it specified in this file
  provisioner "file" {
	source = "files/puma.service"
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
	ports = ["9292"]
  }
  # addresses range to allow access
  source_ranges = ["0.0.0.0/0"]
  # this firewall rule will be applicable for instances with the tags listed in "target_tags"
  target_tags = ["reddit-app"]
}
