resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-actions-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Workload Identity Pool for GitHub Actions"
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Provider"
  description                        = "OIDC provider for GitHub Actions"
  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }
  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
  attribute_condition = "assertion.repository_owner == 'motoki317'"
}

# Direct IAM bindings for the GitHub repository principal
locals {
  github_repository_principal = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/motoki317/toki317.dev"
}

# Grant Editor role directly to the GitHub repository
resource "google_project_iam_member" "github_direct_editor" {
  project = local.project-id
  role    = "roles/editor"
  member  = local.github_repository_principal
}

# Grant Storage Admin for general storage operations
resource "google_project_iam_member" "github_direct_storage_admin" {
  project = local.project-id
  role    = "roles/storage.admin"
  member  = local.github_repository_principal
}

output "workload_identity_provider" {
  value       = google_iam_workload_identity_pool_provider.github_provider.name
  description = "The full identifier of the Workload Identity Provider for GitHub Actions"
}
