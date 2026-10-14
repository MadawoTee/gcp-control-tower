output "workload_identity_provider" {
  description = "Full resource name to put in GitHub Actions' google-github-actions/auth `workload_identity_provider` input"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "service_account_email" {
  value = google_service_account.terraform_ci.email
}
