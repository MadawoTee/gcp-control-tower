/**
 * gke-private-cluster  (Phase 2)
 * --------------------------------
 * A private, VPC-native GKE cluster dropped into one spoke VPC. Deploying
 * one of these per spoke (e.g. one in vpc-dev, another in vpc-staging, or
 * two side-by-side in different VPCs just to practice) is exactly the
 * "different clusters / different VPCs" exercise you described. Because
 * every spoke is wired into the same NCC hub, pods in one cluster can be
 * made reachable from another spoke without merging networks.
 */

resource "google_container_cluster" "this" {
  project  = var.project_id
  name     = var.cluster_name
  location = var.region

  network    = var.network_self_link
  subnetwork = var.subnetwork_self_link

  # GKE Autopilot is the easiest on-ramp; flip to false + node_pool below
  # once you want to hand-tune node pools, taints, and machine types.
  enable_autopilot = var.use_autopilot

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = var.enable_private_endpoint
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks
      content {
        cidr_block   = cidr_blocks.value.cidr
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  release_channel {
    channel = var.release_channel
  }

  deletion_protection = var.deletion_protection

  # Remove the default node pool immediately when not using Autopilot; a
  # standard node pool is defined separately below.
  remove_default_node_pool = !var.use_autopilot
  initial_node_count       = var.use_autopilot ? null : 1
}

resource "google_container_node_pool" "default" {
  count    = var.use_autopilot ? 0 : 1
  project  = var.project_id
  name     = "${var.cluster_name}-pool-1"
  location = var.region
  cluster  = google_container_cluster.this.name

  node_count = var.node_count

  node_config {
    machine_type = var.machine_type
    disk_size_gb = 50
    disk_type    = "pd-standard"

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    tags = ["gke-node", "allow-health-checks"]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
