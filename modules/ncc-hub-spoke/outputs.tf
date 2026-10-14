output "hub_id" {
  value = google_network_connectivity_hub.this.id
}

output "spoke_ids" {
  value = { for k, v in google_network_connectivity_spoke.vpc_spokes : k => v.id }
}
