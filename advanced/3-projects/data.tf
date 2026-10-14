data "terraform_remote_state" "organization" {
  backend = "gcs"
  config = {
    bucket = var.state_bucket
    prefix = "1-organization"
  }
}

data "terraform_remote_state" "networking" {
  backend = "gcs"
  config = {
    bucket = var.state_bucket
    prefix = "2-networking"
  }
}
