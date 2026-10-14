# Reads stage 1's outputs (folder IDs) out of the shared remote state bucket.
data "terraform_remote_state" "organization" {
  backend = "gcs"
  config = {
    bucket = var.state_bucket
    prefix = "1-organization"
  }
}
