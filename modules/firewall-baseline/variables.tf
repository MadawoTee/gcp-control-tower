variable "project_id" {
  type = string
}

variable "network_name" {
  description = "Name of the VPC these rules apply to"
  type        = string
}

variable "internal_cidr_ranges" {
  description = "CIDR ranges considered 'internal' for this VPC (primary + secondary ranges)"
  type        = list(string)
}

variable "health_check_target_tags" {
  description = "Network tags on instances/GKE nodes that should receive health check traffic"
  type        = list(string)
  default     = ["allow-health-checks"]
}

variable "enable_connectivity_test_tag" {
  description = "Whether to open the conn-test tag pair used by tests/connectivity"
  type        = bool
  default     = true
}
