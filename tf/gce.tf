resource "google_compute_instance" "g001" {
  name         = "g001"
  machine_type = "e2-micro"
  zone         = "us-west1-a"

  key_revocation_action_type = "NONE" # Needed in order for plan to result in no diff, for some reason

  boot_disk {
    source = "g001"
  }

  network_interface {
    network = "default"

    access_config {
      network_tier = "STANDARD"
    }
  }

  service_account {
    email = "905974313870-compute@developer.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }
}
