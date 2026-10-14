variable "state_bucket" {
  type = string
}

variable "region" {
  type    = string
  default = "africa-south1"
}

# PHASE 2: one private GKE cluster per environment, each in its own VPC.
# This is the "different clusters / different VPCs" networking exercise —
# every cluster lives behind its own spoke, reachable from the others only
# through the NCC hub built in stage 2.
variable "clusters" {
  type = map(object({
    environment            = string
    master_ipv4_cidr_block = string
    use_autopilot          = bool
  }))
  default = {
    dev = {
      environment            = "dev"
      master_ipv4_cidr_block = "10.10.100.0/28"
      use_autopilot          = true
    }
    staging = {
      environment            = "staging"
      master_ipv4_cidr_block = "10.20.100.0/28"
      use_autopilot          = true
    }
    # prod intentionally left out by default — uncomment when you're ready
    # to pay for a third cluster.
    # prod = {
    #   environment            = "prod"
    #   master_ipv4_cidr_block = "10.30.100.0/28"
    #   use_autopilot          = false
    # }
  }
}
