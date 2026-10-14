variable "org_id" {
  description = "GCP Organization ID (numeric), e.g. 123456789012"
  type        = string
}

variable "top_level_folder_name" {
  description = "Display name for the top-level folder that contains this whole project"
  type        = string
  default     = "learning-lab"
}

variable "environment_names" {
  description = "Environment folders to create under environments/"
  type        = list(string)
  default     = ["dev", "staging", "prod"]
}

variable "create_sandbox_folder" {
  description = "Whether to create a sandbox/ folder for throwaway experiments"
  type        = bool
  default     = true
}

variable "apply_baseline_org_policies" {
  description = "Whether to apply baseline org policy constraints (requires orgpolicy.googleapis.com and Org Policy Admin). Leave false if you don't have org-level admin yet."
  type        = bool
  default     = false
}
