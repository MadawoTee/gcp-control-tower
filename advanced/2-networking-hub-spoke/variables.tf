variable "state_bucket" {
  description = "The terraform_state_bucket output from 0-bootstrap"
  type        = string
}

variable "billing_account" {
  type = string
}

variable "region" {
  type    = string
  default = "africa-south1"
}

# One spoke per environment. CIDRs are pre-planned so they never overlap
# across environments or with the hub, which is exactly what you want to be
# able to reason about when you're learning routing.
variable "environments" {
  description = "Per-environment network configuration"
  type = map(object({
    primary_cidr  = string
    pods_cidr     = string
    services_cidr = string
  }))
  default = {
    dev = {
      primary_cidr  = "10.10.0.0/20"
      pods_cidr     = "10.10.64.0/19"
      services_cidr = "10.10.96.0/22"
    }
    staging = {
      primary_cidr  = "10.20.0.0/20"
      pods_cidr     = "10.20.64.0/19"
      services_cidr = "10.20.96.0/22"
    }
    prod = {
      primary_cidr  = "10.30.0.0/20"
      pods_cidr     = "10.30.64.0/19"
      services_cidr = "10.30.96.0/22"
    }
  }
}

variable "hub_shared_services_cidr" {
  type    = string
  default = "10.0.0.0/24"
}
