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

  # STEP 1: leave this commented out and run `terraform init` + `apply` with
  #         local state first — you can't point at a GCS bucket that this
  #         same apply is about to create.
  # STEP 2: once the bucket exists (see outputs.tf), uncomment this block,
  #         run `terraform init -migrate-state`, and commit the change.
  #
  # backend "gcs" {
  #   bucket = "REPLACE_WITH_terraform_state_bucket_name_output"
  #   prefix = "0-bootstrap"
  # }
}
