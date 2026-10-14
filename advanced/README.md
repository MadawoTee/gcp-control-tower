# Advanced stages (require more than a single VPC — some require an Organization)

These are the stages from the original enterprise-shaped control tower.
They're real, working Terraform — not placeholders — but they're set aside
from the default `0-bootstrap` → `1-networking` path because they assume
things a fresh personal GCP account doesn't have yet:

| Stage | Needs | Unlocked by ticket |
|---|---|---|
| `1-organization/` | A real GCP **Organization** (folders, org policies) | FOUND-1, if you later register a domain + Cloud Identity Free |
| `2-networking-hub-spoke/` | `1-organization`'s folders (as currently written) | NET-5 |
| `3-projects/` | `2-networking-hub-spoke`'s Shared VPC host projects | NET-5 |
| `4-gke/` | `3-projects`' workload projects | GKE-5 |
| `5-ai-apps/` | `3-projects`' dev workload project | (AI epic, once you're multi-project) |

**Worth knowing:** multi-project networking (NCC hub-and-spoke, Shared VPC)
doesn't technically *require* an Organization — only folders and org-wide
policies do. `2-networking-hub-spoke` just happens to be written to pull its
project placement from `1-organization`'s folder outputs. If you want NET-5
before you're ready to buy a domain, the fix is small: point its
`project-factory` calls at `folder_id = null` instead of
`data.terraform_remote_state.organization.outputs.*_folder_id` — ask and
I'll make that cut when you get there.

## Running one of these locally

They're nested one level deeper than the default stages, so the relative
path to the shared tfvars has an extra `../`:

```bash
cd advanced/2-networking-hub-spoke
terraform init -backend-config="bucket=<terraform_state_bucket>"
terraform apply -var-file="../../environments/common.tfvars"
```

## Bringing one into CI

`.github/workflows/terragrunt-plan.yml` and `terragrunt-apply.yml` only run
`terragrunt`, so a stage needs a `terragrunt.hcl` (following the pattern in
`1-networking/terragrunt.hcl` and `tests/connectivity/terragrunt.hcl`)
before it can join their `matrix.stage` list / `workflow_dispatch` input.
Until you convert one, apply it by hand as shown above — there's no plain-
Terraform CI path wired up on purpose, to keep "what CI can apply" and
"what's still hand-applied" unambiguous. Converting a stage is small: add
its `terragrunt.hcl` (`include "root" { path = find_in_parent_folders() }`
plus whatever `inputs`/`dependency` blocks it needs), delete its `backend`
block the same way `1-networking/versions.tf` did, and add its path to both
workflows.
