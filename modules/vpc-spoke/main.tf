/**
 * vpc-spoke
 * ----------
 * A workload VPC ("spoke") for one environment or one learning track
 * (e.g. dev, staging, prod, or "gke-cluster-a" vs "gke-cluster-b" when
 * you're deliberately practicing multi-VPC networking). Includes:
 *   - a regional subnet with secondary ranges for GKE pods/services
 *   - Cloud Router + Cloud NAT so private nodes/VMs get outbound internet
 *   - Private Google Access so nodes can reach Google APIs without public IPs
 *
 * Attach this VPC to Network Connectivity Center (modules/ncc-hub-spoke) to
 * give it transitive reachability to the hub and other spokes.
 */

resource "google_compute_network" "spoke" {
  project                 = var.project_id
  name                    = var.network_name
  auto_create_subnetworks = false
  routing_mode            = var.routing_mode
  description             = "Spoke VPC for ${var.environment}"
}

resource "google_compute_subnetwork" "primary" {
  project                  = var.project_id
  name                     = "${var.network_name}-${var.region}"
  network                  = google_compute_network.spoke.id
  region                   = var.region
  ip_cidr_range            = var.primary_cidr
  private_ip_google_access = true

  dynamic "secondary_ip_range" {
    for_each = var.gke_secondary_ranges
    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.cidr
    }
  }

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_router" "spoke" {
  project = var.project_id
  name    = "${var.network_name}-router-${var.region}"
  network = google_compute_network.spoke.id
  region  = var.region
}

resource "google_compute_router_nat" "spoke" {
  project                            = var.project_id
  name                               = "${var.network_name}-nat-${var.region}"
  router                             = google_compute_router.spoke.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
