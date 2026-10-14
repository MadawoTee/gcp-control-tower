variable "project_id" {
  description = "Dev project id (1-networking's project_id output). Supplied by terragrunt.hcl's dependency block; pass by hand with -var if running plain terraform."
  type        = string
}

variable "subnet_self_link" {
  description = "Dev subnet self_link (1-networking's subnet_self_link output). Same sourcing as project_id."
  type        = string
}

variable "region" {
  type    = string
  default = "africa-south1"
}

variable "zone_suffix" {
  description = "Appended to var.region to pick a zone, e.g. \"-a\""
  type        = string
  default     = "-a"
}
