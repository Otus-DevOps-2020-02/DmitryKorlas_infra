terraform {
  required_version = "~>0.12.0"
  backend "gcs" {
    bucket = "reddit-app-tf-state"
    prefix = "terraform/state/prod"
  }
}
