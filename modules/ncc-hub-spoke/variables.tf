variable "hub_project_id" {
  description = "Project ID that owns the NCC hub resource (typically your networking-hub project)"
  type        = string
}

variable "hub_name" {
  description = "Name of the Network Connectivity Center hub"
  type        = string
  default     = "control-tower-hub"
}

variable "spoke_vpc_self_links" {
  description = "Map of label -> VPC self_link to attach as NCC spokes, e.g. { hub = ..., dev = ..., staging = ..., prod = ... }"
  type        = map(string)
}
