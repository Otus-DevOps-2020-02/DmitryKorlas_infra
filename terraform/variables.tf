variable project {
  description = "Project ID"
}
variable region {
  description = "Region"
  # default value
  default = "europe-west1"
}
variable zone {
  description = "Zone for VM instance"
  default     = "europe-west1-b"
}
variable public_key_path {
  # variable description
  description = "Path to the public key used for ssh access"
}
variable private_key_path {
  description = "Path to the private key used for ssh access"
}
variable disk_image {
  description = "Disk image"
}
variable reddit_instances_count {
  description = "amount of reddit-app instancess"
  default     = 1
}
variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-base"
}
