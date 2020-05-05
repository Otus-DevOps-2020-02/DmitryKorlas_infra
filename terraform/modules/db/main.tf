resource "google_compute_instance" "db" {
  name         = "reddit-db"
  machine_type = "g1-small"
  zone         = var.zone
  tags         = ["reddit-db"]
  metadata = {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }
  connection {
    type        = "ssh"
    host        = self.network_interface[0].access_config[0].nat_ip
    user        = "appuser"
    agent       = false
    private_key = file(var.private_key_path)
  }
  boot_disk {
    initialize_params {
      image = var.db_disk_image
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }

  # copy mongo config to be accassible from the outside of vm
  provisioner "file" {
    source      = "${path.module}/mongod.conf"
    destination = "/tmp/mongod.conf"
  }

  provisioner "remote-exec" {
    inline = ["sudo mv /tmp/mongod.conf /etc/mongod.conf", "sudo systemctl restart mongod"]
  }
}

resource "google_compute_firewall" "firewall_mongo" {
  name    = "allow-mongo-default"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }
  source_tags = ["reddit-app"]
  target_tags = ["reddit-db"]
}
