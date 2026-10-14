output "cluster_names" {
  value = { for k, v in module.cluster : k => v.cluster_name }
}
