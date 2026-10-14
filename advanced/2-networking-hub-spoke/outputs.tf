output "hub_project_id" {
  value = module.hub_project.project_id
}

output "env_net_host_project_ids" {
  value = { for k, v in module.env_net_host_project : k => v.project_id }
}

output "env_vpc_self_links" {
  value = { for k, v in module.env_spoke_vpc : k => v.network_self_link }
}

output "env_subnet_self_links" {
  value = { for k, v in module.env_spoke_vpc : k => v.subnet_self_link }
}

output "ncc_hub_id" {
  value = module.ncc.hub_id
}
