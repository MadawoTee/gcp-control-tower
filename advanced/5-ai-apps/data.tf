data "terraform_remote_state" "networking" {
  backend = "gcs"
  config = {
    bucket = var.state_bucket
    prefix = "2-networking"
  }
}

data "terraform_remote_state" "projects" {
  backend = "gcs"
  config = {
    bucket = var.state_bucket
    prefix = "3-projects"
  }
}
