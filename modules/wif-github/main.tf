/**
 * wif-github
 * -----------
 * Workload Identity Federation so GitHub Actions can authenticate to GCP
 * WITHOUT a downloaded service account key. GitHub presents an OIDC token
 * for the workflow run; GCP exchanges it for short-lived credentials if the
 * token's repo/branch claims match this pool's attribute condition.
 */

resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = var.pool_id
  display_name              = "GitHub Actions pool"
  description               = "Used by GitHub Actions to deploy this control tower via Terraform"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = var.provider_id
  display_name                       = "GitHub OIDC"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  # Only tokens whose "repository" claim matches your repo can mint
  # credentials here. Tighten attribute_condition further (e.g. by ref) once
  # you add environment-specific service accounts.
  attribute_condition = "assertion.repository == \"${var.github_repository}\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account" "terraform_ci" {
  project      = var.project_id
  account_id   = var.service_account_id
  display_name = "Terraform CI/CD runner (GitHub Actions)"
}

# Allow the GitHub identity to impersonate the CI service account.
resource "google_service_account_iam_member" "wif_binding" {
  service_account_id = google_service_account.terraform_ci.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repository}"
}

resource "google_project_iam_member" "ci_roles" {
  for_each = toset(var.ci_service_account_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.terraform_ci.email}"
}
