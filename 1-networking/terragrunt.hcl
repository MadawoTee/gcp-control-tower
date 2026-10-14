include "root" {
  path = find_in_parent_folders()
}

locals {
  common = read_terragrunt_config("${get_repo_root()}/environments/common.hcl")
}

inputs = {
  billing_account     = local.common.locals.billing_account
  region              = local.common.locals.region
  existing_project_id = local.common.locals.existing_project_id
}
