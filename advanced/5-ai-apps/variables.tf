variable "state_bucket" {
  type = string
}

variable "region" {
  type    = string
  default = "africa-south1"
}

variable "zone" {
  type    = string
  default = "africa-south1-a"
}

variable "ai_environment" {
  description = "Which environment's project/VPC hosts the AI app (dev while learning)"
  type        = string
  default     = "dev"
}

variable "create_cloud_run_service" {
  type    = bool
  default = false
}

variable "container_image" {
  type    = string
  default = "gcr.io/cloudrun/hello"
}
