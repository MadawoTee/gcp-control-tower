variable "org_id" {
  description = "Your GCP Organization ID (numeric), if you have one. Find it with: gcloud organizations list. Leave null (the default) for a standalone personal account with no Organization — the seed project is then created with no parent, exactly like a project you'd create by hand in the console."
  type        = string
  default     = null
}

variable "billing_account" {
  description = "Billing account ID to attach to the seed/CI project, e.g. 012345-6789AB-CDEF01. Find it with: gcloud billing accounts list. Ignored (and may be left unset) when existing_project_id is set."
  type        = string
  default     = null
}

variable "existing_project_id" {
  description = "If set, skip creating a new seed project and build the state bucket + WIF pool inside this existing project instead (its real project ID, e.g. \"synthesis-sbx-general\"). Use this when you were handed a project directly rather than given rights to create new ones — common on a shared/company GCP account. seed_project_id_prefix, billing_account, and org_id are all ignored in this mode."
  type        = string
  default     = null
}

variable "seed_project_id_prefix" {
  description = "Project ID prefix for the seed/CI-CD project (must be globally unique; a random suffix is appended). Defaults to a name-scoped prefix rather than a generic one since this is meant to run inside a shared GCP account with other projects already in it — change it to whatever identifies your own sandbox resources."
  type        = string
  default     = "taona-ct-seed"
}

variable "region" {
  description = "Default region for the state bucket and CI resources"
  type        = string
  default     = "africa-south1"
}

variable "github_repository" {
  description = "GitHub repo (owner/repo) that is allowed to deploy via Workload Identity Federation"
  type        = string
}
