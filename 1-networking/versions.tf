terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # No backend block here on purpose: this stage is meant to be run through
  # Terragrunt now, which generates one (terragrunt_generated_backend.tf,
  # written by terragrunt.hcl's `remote_state` block) every time you run
  # `terragrunt init`. Terraform only allows ONE backend block per module,
  # so this file and the generated one can't both declare it.
  #
  # To go back to plain `terraform` (no Terragrunt) for this stage, delete
  # terragrunt_generated_backend.tf and uncomment:
  #   backend "gcs" {
  #     prefix = "1-networking"
  #   }
  # then `terraform init -backend-config="bucket=<...>"` as before.
}
