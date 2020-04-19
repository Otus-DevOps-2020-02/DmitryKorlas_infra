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
