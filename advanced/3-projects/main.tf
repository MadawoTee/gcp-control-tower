/**
 * Stage 3: Projects (workload / "app factory")
 * ==============================================
 * This is the "app factory" part of the control tower: every time you need
 * a new application, team, or workload, you add one entry here (or copy this
 * pattern) rather than hand-creating projects in the console. Each workload
 * project is attached as a Shared VPC *service* project to its environment's
 * spoke VPC from stage 2 — it never creates its own network.
 */

module "app_project" {
  for_each = toset(var.environments)
  source   = "../../modules/project-factory"

  project_id_prefix = "${each.value}-apps"
  folder_id          = data.terraform_remote_state.organization.outputs.env_folder_ids[each.value]
  billing_account    = var.billing_account
  environment        = each.value
  enabled_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "aiplatform.googleapis.com",
    "run.googleapis.com",
    "artifactregistry.googleapis.com",
  ]
}

resource "google_compute_shared_vpc_service_project" "app" {
  for_each = toset(var.environments)

  host_project    = data.terraform_remote_state.networking.outputs.env_net_host_project_ids[each.value]
  service_project = module.app_project[each.value].project_id
}

# GKE's own service agent (and any humans/CI acting as network users) need
# compute.networkUser on the host project's subnet to actually launch
# resources into the shared VPC. Granting it at the host project level here
# keeps this simple; scope it down to the specific subnet in a real org.
resource "google_project_iam_member" "network_user" {
  for_each = toset(var.environments)

  project = data.terraform_remote_state.networking.outputs.env_net_host_project_ids[each.value]
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:${module.app_project[each.value].project_number}@cloudservices.gserviceaccount.com"
}

resource "google_project_iam_member" "gke_host_service_agent" {
  for_each = toset(var.environments)

  project = data.terraform_remote_state.networking.outputs.env_net_host_project_ids[each.value]
  role    = "roles/container.hostServiceAgentUser"
  member  = "serviceAccount:service-${module.app_project[each.value].project_number}@container-engine-robot.iam.gserviceaccount.com"
}
