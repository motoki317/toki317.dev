locals {
  project-id = "hobby-256508"
}

provider "google" {
  project = local.project-id
  region  = "us-west1"
  zone    = "us-west1-a"
}

terraform {
  backend "gcs" {
    bucket = "toki317-dev-tfstate"
  }
}
