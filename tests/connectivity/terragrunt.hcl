include "root" {
  path = find_in_parent_folders()
}

# This is the payoff for converting to Terragrunt: instead of a hand-rolled
# `data "terraform_remote_state" "networking" { ... }` block guessing at the
# bucket name and prefix, this reads 1-networking's real outputs directly —
# and `terragrunt run-all apply` will apply 1-networking first automatically
# because of this dependency, no manual ordering required.
dependency "networking" {
  config_path = "../../1-networking"

  # Lets `terragrunt plan` work even before 1-networking has been applied
  # (e.g. in CI, or the first time you look at this stage).
  mock_outputs = {
    project_id       = "mock-project-id"
    subnet_self_link = "projects/mock-project-id/regions/africa-south1/subnetworks/vpc-dev-africa-south1"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

locals {
  common = read_terragrunt_config("${get_repo_root()}/environments/common.hcl")
}

inputs = {
  project_id       = dependency.networking.outputs.project_id
  subnet_self_link = dependency.networking.outputs.subnet_self_link
  region           = local.common.locals.region
}
