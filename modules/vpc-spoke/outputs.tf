output "network_id" {
  value = google_compute_network.spoke.id
}

output "network_self_link" {
  value = google_compute_network.spoke.self_link
}

output "network_name" {
  value = google_compute_network.spoke.name
}

output "subnet_self_link" {
  value = google_compute_subnetwork.primary.self_link
}

output "subnet_name" {
  value = google_compute_subnetwork.primary.name
}
