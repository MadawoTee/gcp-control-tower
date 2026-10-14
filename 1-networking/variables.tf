variable "billing_account" {
  description = "Billing account ID, e.g. 012345-6789AB-CDEF01"
  type        = string
}

variable "project_id_prefix" {
  description = "Project ID prefix for the single dev project this stage creates (a random suffix keeps it globally unique). Name-scoped by default for the same reason as 0-bootstrap's seed_project_id_prefix — shared account, several other projects already in it."
  type        = string
  default     = "taona-learning-lab-dev"
}

variable "region" {
  type    = string
  default = "africa-south1"
}

variable "network_name" {
  type    = string
  default = "vpc-dev"
}

variable "primary_cidr" {
  description = "Primary subnet CIDR (where GKE nodes will eventually live)"
  type        = string
  default     = "10.10.0.0/22"
}

variable "pods_cidr" {
  description = "Secondary range for GKE pods, reserved now so Phase 3 doesn't need to touch this VPC"
  type        = string
  default     = "10.10.64.0/19"
}

variable "services_cidr" {
  description = "Secondary range for GKE services, reserved now for the same reason"
  type        = string
  default     = "10.10.96.0/22"
}
