/**
 * project-factory
 * ----------------
 * Creates a single GCP project, links it to billing, places it in the
 * requested folder, and enables a baseline set of APIs. Call this module
 * once per project you want (networking-hub, dev-apps, staging-apps, ...).
 */

resource "random_id" "suffix" {
  count       = var.random_project_id_suffix ? 1 : 0
  byte_length = 2
}

locals {
  project_id = var.random_project_id_suffix ? "${var.project_id_prefix}-${random_id.suffix[0].hex}" : var.project_id_prefix
}

resource "google_project" "this" {
  name                = var.project_name != "" ? var.project_name : local.project_id
  project_id          = local.project_id
  folder_id           = var.folder_id
  billing_account     = var.billing_account
  auto_create_network = false

  labels = merge(
    {
      environment = var.environment
      managed_by  = "terraform"
      stack       = "gcp-control-tower"
    },
    var.labels
  )
}

resource "google_project_service" "apis" {
  for_each = toset(var.enabled_apis)

  project                    = google_project.this.project_id
  service                    = each.value
  disable_dependent_services = false
  disable_on_destroy         = false
}
