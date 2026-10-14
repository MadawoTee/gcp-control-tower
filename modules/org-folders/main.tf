/**
 * org-folders
 * ------------
 * Creates the folder hierarchy under the GCP Organization that every other
 * stage places projects into. This is the "shelving" of the control tower:
 *
 *   Organization
 *   └── learning-lab                 (top-level folder for this whole project)
 *       ├── bootstrap                (seed / CI-CD project lives here)
 *       ├── networking               (hub VPC + shared network projects)
 *       ├── environments
 *       │   ├── dev
 *       │   ├── staging
 *       │   └── prod
 *       └── sandbox                  (throwaway experiments, deleted freely)
 */

resource "google_folder" "top_level" {
  display_name = var.top_level_folder_name
  parent       = "organizations/${var.org_id}"
}

resource "google_folder" "bootstrap" {
  display_name = "bootstrap"
  parent       = google_folder.top_level.name
}

resource "google_folder" "networking" {
  display_name = "networking"
  parent       = google_folder.top_level.name
}

resource "google_folder" "environments" {
  display_name = "environments"
  parent       = google_folder.top_level.name
}

resource "google_folder" "envs" {
  for_each     = toset(var.environment_names)
  display_name = each.value
  parent       = google_folder.environments.name
}

resource "google_folder" "sandbox" {
  count        = var.create_sandbox_folder ? 1 : 0
  display_name = "sandbox"
  parent       = google_folder.top_level.name
}

# Baseline org policies applied at the top-level folder so every project
# underneath inherits them. Kept intentionally small for a learning project;
# tighten these once you understand what each one does.
resource "google_org_policy_policy" "require_os_login" {
  count  = var.apply_baseline_org_policies ? 1 : 0
  name   = "${google_folder.top_level.name}/policies/compute.requireOsLogin"
  parent = google_folder.top_level.name

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}

resource "google_org_policy_policy" "skip_default_network" {
  count  = var.apply_baseline_org_policies ? 1 : 0
  name   = "${google_folder.top_level.name}/policies/compute.skipDefaultNetworkCreation"
  parent = google_folder.top_level.name

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}

resource "google_org_policy_policy" "restrict_public_ip_gke" {
  count  = var.apply_baseline_org_policies ? 1 : 0
  name   = "${google_folder.top_level.name}/policies/container.restrictPodTrafficToDefaultDeny"
  parent = google_folder.top_level.name

  spec {
    rules {
      enforce = "TRUE"
    }
  }
}
