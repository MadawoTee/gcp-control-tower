variable "project_id" {
  description = "Project ID where the hub VPC lives (typically your networking-hub project)"
  type        = string
}

variable "network_name" {
  description = "Name of the hub VPC"
  type        = string
  default     = "vpc-hub"
}

variable "region" {
  description = "Primary region for the hub subnet and router"
  type        = string
}

variable "shared_services_cidr" {
  description = "CIDR range for the hub's shared-services subnet"
  type        = string
  default     = "10.0.0.0/24"
}

variable "enable_dns_inbound_forwarding" {
  description = "Whether to create a Cloud DNS inbound forwarding policy on the hub VPC"
  type        = bool
  default     = true
}
