variable "project_id_prefix" {
  description = "Desired project ID (or prefix, if random_project_id_suffix is true). Must be globally unique across all of GCP."
  type        = string
}

variable "project_name" {
  description = "Human friendly project display name. Defaults to the project id."
  type        = string
  default     = ""
}

variable "random_project_id_suffix" {
  description = "Append a random 4-char hex suffix to project_id_prefix to guarantee global uniqueness. Recommended true while learning."
  type        = bool
  default     = true
}

variable "folder_id" {
  description = "Folder resource name to place the project in, e.g. folders/123456789. Leave null for a standalone project with no Organization/folder parent (the default for a personal GCP account)."
  type        = string
  default     = null
}

variable "billing_account" {
  description = "Billing account ID, e.g. 012345-6789AB-CDEF01. Ignored (and may be left null) when existing_project_id is set — an existing project's billing is already attached by whoever created it."
  type        = string
  default     = null
}

variable "existing_project_id" {
  description = "If set, skip creating a new project and reuse this one (its real project ID, e.g. \"synthesis-sbx-general\") instead. Use this when you've been handed a project directly rather than given rights to create new ones (roles/resourcemanager.projects.create is often restricted on a shared/company account). project_id_prefix, billing_account, folder_id, and labels are all ignored in this mode — the project's identity, billing, parent, and labels stay whatever they already were."
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment label: bootstrap | networking | dev | staging | prod | sandbox"
  type        = string
}

variable "enabled_apis" {
  description = "List of Google API services to enable on this project"
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ]
}

variable "labels" {
  description = "Extra labels to merge onto the project"
  type        = map(string)
  default     = {}
}
