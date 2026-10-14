variable "org_id" {
  type = string
}

variable "top_level_folder_name" {
  type    = string
  default = "learning-lab"
}

variable "apply_baseline_org_policies" {
  description = "Requires org-level Org Policy Admin. Leave false until you've confirmed you have that role."
  type        = bool
  default     = false
}
