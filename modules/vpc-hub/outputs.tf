output "network_id" {
  value = google_compute_network.hub.id
}

output "network_self_link" {
  value = google_compute_network.hub.self_link
}

output "network_name" {
  value = google_compute_network.hub.name
}

output "router_id" {
  value = google_compute_router.hub.id
}
