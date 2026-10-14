terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  # See 1-networking/versions.tf's comment — no backend block here on
  # purpose; Terragrunt generates one.
}
