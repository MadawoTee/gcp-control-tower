/**
 * firewall-baseline
 * ------------------
 * A small, sane starting firewall policy for a VPC:
 *   - implied default-deny-ingress (GCP default; nothing to create)
 *   - allow SSH/RDP only via Identity-Aware Proxy (IAP), never open to 0.0.0.0/0
 *   - allow all internal traffic within the VPC's CIDR ranges
 *   - allow Google/GKE health checks to reach backends
 *   - allow the connectivity-test tag so tests/connectivity can probe hosts
 */

resource "google_compute_firewall" "allow_iap_ssh_rdp" {
  project       = var.project_id
  name          = "${var.network_name}-allow-iap-ssh-rdp"
  network       = var.network_name
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["35.235.240.0/20"] # Google's IAP TCP forwarding range

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }
}

resource "google_compute_firewall" "allow_internal" {
  project       = var.project_id
  name          = "${var.network_name}-allow-internal"
  network       = var.network_name
  direction     = "INGRESS"
  priority      = 1000
  source_ranges = var.internal_cidr_ranges

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }
}

resource "google_compute_firewall" "allow_health_checks" {
  project = var.project_id
  name    = "${var.network_name}-allow-health-checks"
  network = var.network_name
  direction = "INGRESS"
  priority  = 1000

  # Google's documented health check source ranges
  source_ranges = [
    "35.191.0.0/16",
    "130.211.0.0/22",
    "209.85.152.0/22",
    "209.85.204.0/22",
  ]

  allow {
    protocol = "tcp"
  }

  target_tags = var.health_check_target_tags
}

resource "google_compute_firewall" "allow_connectivity_test" {
  count   = var.enable_connectivity_test_tag ? 1 : 0
  project = var.project_id
  name    = "${var.network_name}-allow-connectivity-test"
  network = var.network_name
  direction = "INGRESS"
  priority  = 1000

  source_tags = ["conn-test"]
  target_tags = ["conn-test"]

  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
}
