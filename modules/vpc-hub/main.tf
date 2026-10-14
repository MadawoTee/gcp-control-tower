/**
 * vpc-hub
 * --------
 * The "hub" VPC in a hub-and-spoke topology. It does not run application
 * workloads. It hosts shared services that every spoke needs to reach:
 *   - a DNS forwarding/inbound policy (Cloud DNS)
 *   - optionally a bastion / network virtual appliance (NVA) subnet
 *   - the on-prem / VPN or Interconnect attachment point (future)
 *
 * The hub VPC itself gets attached to Network Connectivity Center as just
 * another spoke (see modules/ncc-hub-spoke) — NCC's "hub" is a logical
 * routing construct, separate from this VPC.
 */

resource "google_compute_network" "hub" {
  project                 = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  description             = "Hub VPC for shared services (DNS, bastion, on-prem connectivity)"
}

resource "google_compute_subnetwork" "hub_shared_services" {
  project                  = var.project_id
  name                     = "${var.network_name}-shared-svcs-${var.region}"
  network                  = google_compute_network.hub.id
  region                   = var.region
  ip_cidr_range            = var.shared_services_cidr
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Cloud Router in the hub, useful once you add Cloud VPN / Interconnect to
# an on-prem network or another cloud, and required for Cloud NAT.
resource "google_compute_router" "hub" {
  project = var.project_id
  name    = "${var.network_name}-router-${var.region}"
  network = google_compute_network.hub.id
  region  = var.region
}

# Inbound DNS forwarding so on-prem (future) or peered networks can resolve
# names published in this project's private zones.
resource "google_dns_policy" "inbound_forwarding" {
  count                     = var.enable_dns_inbound_forwarding ? 1 : 0
  project                   = var.project_id
  name                      = "${var.network_name}-inbound-dns"
  enable_inbound_forwarding = true

  networks {
    network_url = google_compute_network.hub.id
  }
}
