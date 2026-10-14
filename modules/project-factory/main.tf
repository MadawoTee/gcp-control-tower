/**
 * project-factory
 * ----------------
 * Creates a single GCP project, links it to billing, places it in the
 * requested folder, and enables a baseline set of APIs. Call this module
 * once per project you want (networking-hub, dev-apps, staging-apps, ...).
 *
 * Set existing_project_id instead to skip creation entirely and reuse a
 * project you were handed directly — common on a shared account where
 * project creation itself is restricted. Either way the module's outputs
 * (project_id, project_number, project_name) work the same, so nothing
 * downstream (vpc-spoke, firewall-baseline, ...) needs to know which mode
 * is in use.
 */

resource "random_id" "suffix" {
  count       = var.existing_project_id == null && var.random_project_id_suffix ? 1 : 0
  byte_length = 2
}

locals {
  project_id = (
    var.existing_project_id != null
    ? var.existing_project_id
    : (var.random_project_id_suffix ? "${var.project_id_prefix}-${random_id.suffix[0].hex}" : var.project_id_prefix)
  )
}

resource "google_project" "this" {
  count = var.existing_project_id == null ? 1 : 0

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

# Only used in existing_project_id mode, to read back project_number/name
# without Terraform trying to manage (or recreate) the project itself.
data "google_project" "existing" {
  count = var.existing_project_id != null ? 1 : 0

  project_id = var.existing_project_id
}

resource "google_project_service" "apis" {
  for_each = toset(var.enabled_apis)

  project                    = local.project_id
  service                    = each.value
  disable_dependent_services = false
  disable_on_destroy         = false
}
