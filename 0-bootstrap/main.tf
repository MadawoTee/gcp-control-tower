/**
 * Stage 0: Bootstrap
 * ===================
 * The one stage you apply by hand, with your own `gcloud auth
 * application-default login` credentials, before any CI/CD pipeline exists.
 * It creates:
 *   1. A seed project (holds Terraform state + the CI/CD identity)
 *   2. A versioned GCS bucket for all later stages' remote state
 *   3. A Workload Identity Federation pool so GitHub Actions can deploy
 *      later stages without ever holding a service account key
 *
 * var.org_id defaults to null, so by default this creates a plain
 * standalone project — exactly what a personal GCP account (no
 * Organization) needs. If you later register a domain and set up Cloud
 * Identity Free, pass org_id and re-apply to bring this project under real
 * org governance; see advanced/1-organization for the folder hierarchy that
 * unlocks.
 *
 * Run this once, then never touch it again except to rotate/extend WIF.
 */

resource "random_id" "seed_suffix" {
  byte_length = 2
}

resource "google_project" "seed" {
  name                = "Control Tower Seed"
  project_id          = "${var.seed_project_id_prefix}-${random_id.seed_suffix.hex}"
  org_id              = var.org_id
  billing_account     = var.billing_account
  auto_create_network = false

  labels = {
    managed_by = "terraform"
    stack      = "gcp-control-tower"
    stage      = "bootstrap"
  }
}

locals {
  seed_project_id = google_project.seed.project_id
}

resource "google_project_service" "seed_apis" {
  for_each = toset([
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "storage.googleapis.com",
    "compute.googleapis.com",
    "orgpolicy.googleapis.com",
    "cloudbilling.googleapis.com",
  ])
  project = local.seed_project_id
  service = each.value
}

# ---------------------------------------------------------------------------
# Terraform remote state bucket, shared by every later stage (each stage uses
# its own `prefix` inside the same bucket).
# ---------------------------------------------------------------------------
resource "google_storage_bucket" "terraform_state" {
  project                     = local.seed_project_id
  name                        = "${local.seed_project_id}-tfstate"
  location                    = var.region
  force_destroy               = false
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  soft_delete_policy {
    retention_duration_seconds = 604800 # 7 days
  }

  depends_on = [google_project_service.seed_apis]
}

# ---------------------------------------------------------------------------
# Workload Identity Federation for GitHub Actions (see modules/wif-github)
# ---------------------------------------------------------------------------
module "wif_github" {
  source = "../modules/wif-github"

  project_id        = local.seed_project_id
  github_repository = var.github_repository

  depends_on = [google_project_service.seed_apis]
}
