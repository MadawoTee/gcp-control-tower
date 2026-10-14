/**
 * ncc-hub-spoke
 * --------------
 * Wires a set of VPCs together with Network Connectivity Center (NCC).
 * Unlike VPC Peering, NCC spokes get full transitive routing through the
 * hub: spoke A can reach spoke B without a direct peering link between
 * them, and there's no peering-count limit to worry about. This is the
 * modern recommended way to connect many VPCs (dev/staging/prod, or one
 * VPC per GKE cluster) for exactly the "advanced networking" practice
 * you're after.
 */

resource "google_network_connectivity_hub" "this" {
  project     = var.hub_project_id
  name        = var.hub_name
  description = "Control tower hub connecting all spoke VPCs"
}

resource "google_network_connectivity_spoke" "vpc_spokes" {
  for_each = var.spoke_vpc_self_links

  project     = var.hub_project_id
  name        = "${var.hub_name}-spoke-${each.key}"
  location    = "global"
  hub         = google_network_connectivity_hub.this.id
  description = "NCC spoke for the ${each.key} VPC"

  linked_vpc_network {
    uri = each.value
  }
}
