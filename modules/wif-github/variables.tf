variable "project_id" {
  description = "Project where the WIF pool and CI service account live (typically your bootstrap project)"
  type        = string
}

variable "pool_id" {
  type    = string
  default = "github-actions-pool"
}

variable "provider_id" {
  type    = string
  default = "github-actions-provider"
}

variable "service_account_id" {
  type    = string
  default = "terraform-ci"
}

variable "github_repository" {
  description = "GitHub repo allowed to assume this identity, in \"owner/repo\" form"
  type        = string
}

variable "ci_service_account_roles" {
  description = "Roles granted to the CI service account on this project. In a real org, grant per-project roles at each target project instead of broad org-wide roles."
  type        = list(string)
  default = [
    "roles/resourcemanager.folderAdmin",
    "roles/compute.networkAdmin",
    "roles/container.admin",
    "roles/iam.serviceAccountAdmin",
    "roles/serviceusage.serviceUsageAdmin",
  ]
}
