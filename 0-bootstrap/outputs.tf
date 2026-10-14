output "seed_project_id" {
  value = local.seed_project_id
}

output "terraform_state_bucket" {
  description = "Copy this into every later stage's versions.tf backend \"gcs\" block, and into 0-bootstrap/versions.tf itself once you migrate state"
  value       = google_storage_bucket.terraform_state.name
}

output "workload_identity_provider" {
  description = "Copy into .github/workflows/*.yml as `workload_identity_provider`"
  value       = module.wif_github.workload_identity_provider
}

output "ci_service_account_email" {
  description = "Copy into .github/workflows/*.yml as `service_account`"
  value       = module.wif_github.service_account_email
}
