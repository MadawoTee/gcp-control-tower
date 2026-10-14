terraform {
  required_version = ">= 1.7.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }

  backend "gcs" {
    # bucket = set via -backend-config="bucket=<terraform_state_bucket from 0-bootstrap output>"
    prefix = "1-organization"
  }
}
