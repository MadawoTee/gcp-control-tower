/**
 * Stage 1: Organization
 * ======================
 * Builds the folder hierarchy described in modules/org-folders. Applied by
 * the CI/CD pipeline (or by hand, the first time) using the WIF identity
 * created in stage 0.
 */

module "org_folders" {
  source = "../../modules/org-folders"

  org_id                      = var.org_id
  top_level_folder_name       = var.top_level_folder_name
  apply_baseline_org_policies = var.apply_baseline_org_policies
}
