variable "state_bucket" {
  type = string
}

variable "billing_account" {
  type = string
}

variable "environments" {
  description = "Which environments to create a workload/app project for"
  type        = list(string)
  default     = ["dev", "staging", "prod"]
}
