variable "project_id" {
  description = "Project ID where this spoke VPC lives"
  type        = string
}

variable "network_name" {
  description = "Name of the spoke VPC, e.g. vpc-dev, vpc-staging, vpc-gke-a"
  type        = string
}

variable "environment" {
  description = "Environment label for this spoke: dev | staging | prod | sandbox"
  type        = string
}

variable "region" {
  description = "Primary region for this spoke's subnet"
  type        = string
}

variable "routing_mode" {
  description = "VPC routing mode"
  type        = string
  default     = "REGIONAL"
}

variable "primary_cidr" {
  description = "Primary CIDR range for nodes/VMs in this spoke"
  type        = string
}

variable "gke_secondary_ranges" {
  description = "Secondary ranges for GKE pods/services, e.g. [{range_name=\"pods\", cidr=\"10.10.64.0/19\"}, {range_name=\"services\", cidr=\"10.10.96.0/22\"}]"
  type = list(object({
    range_name = string
    cidr       = string
  }))
  default = []
}
