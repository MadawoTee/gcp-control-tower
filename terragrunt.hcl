# Root Terragrunt config. Every stage's terragrunt.hcl does
#   include "root" { path = find_in_parent_folders() }
# to inherit the remote_state and generate blocks below, so backend and
# provider configuration live in exactly one place instead of being
# copy-pasted into every stage (compare 0-bootstrap and advanced/, which
# predate this and still hand-write both).
#
# 0-bootstrap is deliberately NOT converted to Terragrunt: it's the one
# stage that creates the GCS bucket this remote_state block points at, so
# it can't depend on that bucket already existing. It stays plain
# Terraform, applied once by hand — see 0-bootstrap/versions.tf.

locals {
  common = read_terragrunt_config("${get_repo_root()}/environments/common.hcl")
}

remote_state {
  backend = "gcs"

  generate = {
    path      = "terragrunt_generated_backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    bucket = local.common.locals.state_bucket
    # One prefix per stage, matching its path from the repo root exactly
    # (1-networking, advanced/2-networking-hub-spoke, tests/connectivity, ...) —
    # no more manually keeping a `prefix = "..."` in sync with the directory name.
    prefix = path_relative_to_include()
  }
}

generate "provider" {
  path      = "terragrunt_generated_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "google" {
  region = "${local.common.locals.region}"
}

provider "google-beta" {
  region = "${local.common.locals.region}"
}
EOF
}
