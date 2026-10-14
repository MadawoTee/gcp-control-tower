variable "project_id" { type = string }
variable "cluster_name" { type = string }
variable "region" { type = string }
variable "network_self_link" { type = string }
variable "subnetwork_self_link" { type = string }
variable "pods_range_name" {
  type    = string
  default = "pods"
}
variable "services_range_name" {
  type    = string
  default = "services"
}

variable "use_autopilot" {
  description = "Use GKE Autopilot (recommended while learning) instead of managing node pools yourself"
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "If true, the control plane has no public IP at all (you must reach it via VPN/IAP/bastion). Keep false while learning unless you already have that connectivity."
  type        = bool
  default     = false
}

variable "master_ipv4_cidr_block" {
  description = "/28 CIDR for the GKE control plane, must not overlap with any other range in the VPC"
  type        = string
}

variable "master_authorized_networks" {
  description = "CIDR ranges allowed to reach the (public) control plane endpoint"
  type = list(object({
    cidr         = string
    display_name = string
  }))
  default = []
}

variable "release_channel" {
  type    = string
  default = "REGULAR"
}

variable "deletion_protection" {
  description = "Set false so `terraform destroy` can tear this down during learning; set true once real workloads live here"
  type        = bool
  default     = false
}

variable "node_count" {
  type    = number
  default = 1
}

variable "machine_type" {
  type    = string
  default = "e2-standard-2"
}
