/**
 * Stage 4: GKE  (Phase 2)
 * =========================
 * Deploys a private GKE cluster into each environment's spoke VPC and
 * workload project. Left disabled by default in most guides — here it's
 * just another stage, applied once you're happy with stage 2's networking
 * and have run tests/connectivity successfully.
 */

module "cluster" {
  for_each = var.clusters
  source   = "../../modules/gke-private-cluster"

  project_id           = data.terraform_remote_state.projects.outputs.app_project_ids[each.value.environment]
  cluster_name         = "gke-${each.key}"
  region               = var.region
  network_self_link    = data.terraform_remote_state.networking.outputs.env_vpc_self_links[each.value.environment]
  subnetwork_self_link = data.terraform_remote_state.networking.outputs.env_subnet_self_links[each.value.environment]

  master_ipv4_cidr_block = each.value.master_ipv4_cidr_block
  use_autopilot          = each.value.use_autopilot

  # While learning, allow your own IP or Cloud Shell to reach the (public)
  # control plane endpoint. Tighten to a bastion/VPN CIDR for anything real.
  master_authorized_networks = [
    { cidr = "0.0.0.0/0", display_name = "learning-anywhere-TIGHTEN-ME" }
  ]

  deletion_protection = false
}
