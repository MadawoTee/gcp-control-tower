output "app_project_ids" {
  value = { for k, v in module.app_project : k => v.project_id }
}
