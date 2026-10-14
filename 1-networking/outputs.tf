output "project_id" {
  value = module.dev_project.project_id
}

output "network_self_link" {
  value = module.dev_vpc.network_self_link
}

output "network_name" {
  value = module.dev_vpc.network_name
}

output "subnet_self_link" {
  value = module.dev_vpc.subnet_self_link
}
