provider "google" {
  project = "hobby-256508"
  region  = "us-west1"
  zone    = "us-west1-a"
}

terraform {
  backend "gcs" {
    bucket = "toki317-dev-tfstate"
  }
}
