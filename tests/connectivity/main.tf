/**
 * tests/connectivity  (tickets NET-2, NET-4)
 * =============================================
 * A single throwaway "probe" VM in the dev VPC from stage 1-networking,
 * used to prove two things before you build anything on top of this
 * network: Cloud NAT egress (the VM has no external IP) and internal DNS
 * resolution. No cross-VPC test yet — there's only one VPC until NET-5
 * (advanced/2-networking-hub-spoke) adds more.
 *
 * Usage: see run_connectivity_tests.sh in this same folder.
 */

resource "google_compute_instance" "probe" {
  project      = var.project_id
  name         = "conn-test-dev"
  zone         = "${var.region}${var.zone_suffix}"
  machine_type = "e2-micro"

  tags = ["conn-test"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
    }
  }

  network_interface {
    subnetwork = var.subnet_self_link
    # Deliberately no access_config block => no external IP. Reachability is
    # via IAP (SSH) and, for the egress test, via the Cloud NAT set up in
    # 1-networking's vpc-spoke module.
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  labels = {
    purpose = "connectivity-test"
  }
}

output "probe_instance" {
  value = {
    name        = google_compute_instance.probe.name
    zone        = google_compute_instance.probe.zone
    project     = google_compute_instance.probe.project
    internal_ip = google_compute_instance.probe.network_interface[0].network_ip
  }
}
