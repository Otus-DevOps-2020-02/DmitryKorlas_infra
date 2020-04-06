variable project {
  description = "Project ID"
}
variable region {
  description = "Region"
  # default value
  default = "europe-west1"
}
variable public_key_path {
  # variable description
  description = "Path to the public key used for ssh access"
}
variable disk_image {
  description = "Disk image"
}
