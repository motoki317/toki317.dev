resource "google_storage_bucket" "toki317-dev-tfstate" {
  name          = "toki317-dev-tfstate"
  location      = "us-west1"
  storage_class = "REGIONAL"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 5
    }
  }
}
