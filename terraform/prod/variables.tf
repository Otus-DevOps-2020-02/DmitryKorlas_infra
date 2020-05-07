variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable zone {
  description = "Zone for VM instance"
  default     = "europe-west1-b"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-base"
}

variable enable_app_provisioning {
  description = "Enable app provisioning by puma application"
  type = bool
  default = true
}

variable enable_db_provisioning {
  description = "Enable db provisioning"
  type = bool
  default = true
}

variable vpc_ssh_allowed_range {
  description = "A list of addresses to access via ssh"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
