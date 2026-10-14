output "cloud_run_url" {
  value = try(google_cloud_run_v2_service.ai_app[0].uri, null)
}

output "notebook_name" {
  value = try(google_workbench_instance.notebook[0].name, null)
}
