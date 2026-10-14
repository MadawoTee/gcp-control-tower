output "project_id" {
  value = local.project_id
}

output "project_number" {
  value = var.existing_project_id != null ? data.google_project.existing[0].number : google_project.this[0].number
}

output "project_name" {
  value = var.existing_project_id != null ? data.google_project.existing[0].name : google_project.this[0].name
}
