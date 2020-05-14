resource google_compute_instance "app" {
  name         = "reddit-app"
  machine_type = "g1-small"
  zone         = var.zone
  tags         = ["reddit-app"]
  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  // TODO (dkorlas) check if connection still needed here due to it moved into null_resource
  connection {
    type        = "ssh"
    host        = self.network_interface[0].access_config[0].nat_ip
    user        = "appuser"
    agent       = false
    private_key = file(var.private_key_path)
  }
  boot_disk {
    initialize_params { image = var.app_disk_image }
  }
  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.app_ip.address
    }
  }
}

# null_resource is used to make provisioning optional.
resource null_resource "app" {
  count = var.enable_provisioning ? 1 : 0

  connection {
    type        = "ssh"
    host        =  google_compute_instance.app.network_interface[0].access_config[0].nat_ip
    user        = "appuser"
    agent       = false
    private_key = file(var.private_key_path)
  }

  # set autostart scripts
  provisioner "file" {
    source      = "${path.module}/puma.service"
    destination = "/tmp/puma.service"
  }

  # set env variables
  provisioner "file" {
    content     = templatefile("${path.module}/.puma.env.tmpl", { mongodb_url = var.mongodb_url })
    destination = "/home/appuser/.puma.env"
  }

  # install app
  provisioner "remote-exec" {
    script = "${path.module}/deploy.sh"
  }
}

resource "google_compute_address" "app_ip" {
  name = "reddit-app-ip"
}

resource "google_compute_firewall" "firewall_puma" {
  name    = "allow-puma-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["9292", "80"]
  }
  source_ranges = ["0.0.0.0/0"]
  # this firewall rule will be applicable for instances with the tags listed in "target_tags"
  target_tags = ["reddit-app"]
}
