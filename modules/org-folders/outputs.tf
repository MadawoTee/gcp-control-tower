output "top_level_folder_id" {
  value = google_folder.top_level.name
}

output "bootstrap_folder_id" {
  value = google_folder.bootstrap.name
}

output "networking_folder_id" {
  value = google_folder.networking.name
}

output "environments_folder_id" {
  value = google_folder.environments.name
}

output "env_folder_ids" {
  description = "Map of environment name -> folder id, e.g. { dev = \"folders/123\" }"
  value       = { for k, v in google_folder.envs : k => v.name }
}

output "sandbox_folder_id" {
  value = try(google_folder.sandbox[0].name, null)
}
