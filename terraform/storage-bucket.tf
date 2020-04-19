terraform {
  # terraform version
  required_version = "~>0.12.0"
}

provider "google" {
  version = "2.15"
  project = var.project
  region  = var.region
}

module "storage-bucket" {
  source   = "SweetOps/storage-bucket/google"
  version  = "0.3.1"
  name     = "tmp-reddit-app-storage-bucket-test"
  location = var.region
}

output storage-bucket_url {
  value = module.storage-bucket.url
}
