/**
 * Stage 2: Networking
 * ====================
 * This is the heart of the "advanced networking" learning goal. It builds:
 *
 *   networking-hub project ─── hub VPC (shared services, future VPN/Interconnect)
 *   dev-net-host project    ─── vpc-dev     (Shared VPC host for dev)
 *   staging-net-host project─── vpc-staging (Shared VPC host for staging)
 *   prod-net-host project   ─── vpc-prod    (Shared VPC host for prod)
 *
 * All four VPCs are then wired together with Network Connectivity Center,
 * so any spoke can reach any other spoke (and the hub) with full transitive
 * routing — no direct peering links, no peering-limit ceiling.
 *
 * Stage 3 attaches workload ("service") projects to each environment's host
 * project via Shared VPC, so app/GKE workloads never own their own VPC —
 * they borrow the environment's spoke. That combination (Shared VPC *within*
 * an environment, NCC hub-and-spoke *across* environments) mirrors how real
 * GCP landing zones are built.
 */

# ---------------------------------------------------------------------------
# Hub
# ---------------------------------------------------------------------------
module "hub_project" {
  source = "../../modules/project-factory"

  project_id_prefix = "networking-hub"
  folder_id         = data.terraform_remote_state.organization.outputs.networking_folder_id
  billing_account   = var.billing_account
  environment       = "networking"
  enabled_apis = [
    "compute.googleapis.com",
    "dns.googleapis.com",
    "networkconnectivity.googleapis.com",
    "servicenetworking.googleapis.com",
  ]
}

module "hub_vpc" {
  source = "../../modules/vpc-hub"

  project_id           = module.hub_project.project_id
  region               = var.region
  shared_services_cidr = var.hub_shared_services_cidr
}

module "hub_firewall" {
  source = "../../modules/firewall-baseline"

  project_id           = module.hub_project.project_id
  network_name         = module.hub_vpc.network_name
  internal_cidr_ranges = [var.hub_shared_services_cidr]
}

# ---------------------------------------------------------------------------
# Per-environment spoke: one Shared VPC host project + VPC per environment
# ---------------------------------------------------------------------------
module "env_net_host_project" {
  for_each = var.environments
  source   = "../../modules/project-factory"

  project_id_prefix = "${each.key}-net-host"
  folder_id         = data.terraform_remote_state.organization.outputs.env_folder_ids[each.key]
  billing_account   = var.billing_account
  environment       = each.key
  enabled_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "networkconnectivity.googleapis.com",
    "servicenetworking.googleapis.com",
  ]
}

module "env_spoke_vpc" {
  for_each = var.environments
  source   = "../../modules/vpc-spoke"

  project_id   = module.env_net_host_project[each.key].project_id
  network_name = "vpc-${each.key}"
  environment  = each.key
  region       = var.region
  primary_cidr = each.value.primary_cidr

  gke_secondary_ranges = [
    { range_name = "pods", cidr = each.value.pods_cidr },
    { range_name = "services", cidr = each.value.services_cidr },
  ]
}

module "env_firewall" {
  for_each = var.environments
  source   = "../../modules/firewall-baseline"

  project_id   = module.env_net_host_project[each.key].project_id
  network_name = module.env_spoke_vpc[each.key].network_name
  internal_cidr_ranges = [
    each.value.primary_cidr,
    each.value.pods_cidr,
    each.value.services_cidr,
  ]
}

# Turn each environment host project into an actual Shared VPC host, ready
# for stage 3 to attach service (workload) projects to.
resource "google_compute_shared_vpc_host_project" "env" {
  for_each = var.environments
  project  = module.env_net_host_project[each.key].project_id

  depends_on = [module.env_spoke_vpc]
}

# ---------------------------------------------------------------------------
# Network Connectivity Center: hub + one spoke per VPC (hub VPC included)
# ---------------------------------------------------------------------------
module "ncc" {
  source = "../../modules/ncc-hub-spoke"

  hub_project_id = module.hub_project.project_id
  hub_name       = "control-tower-hub"

  spoke_vpc_self_links = merge(
    { hub = module.hub_vpc.network_self_link },
    { for k, v in module.env_spoke_vpc : k => v.network_self_link }
  )
}
