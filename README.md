# GCP Learning Lab / Control Tower

A cost-conscious, personal-account GCP landing zone built progressively
with Terraform — no Organization required to start. Phase 1 gets you a
standalone project, a proven VPC, Cloud NAT, and a firewall baseline.
Kubernetes, security, observability, and AI/ML land on top of that once
each phase is proven, following the ticket backlog.

See the **[Learning Lab Roadmap](https://claude.ai/artifact/QoBRZajCB9WNBoL2MwtFYG)**
and **[Learning Lab Backlog](https://claude.ai/artifact/SNmXBAGFQK6oKwhGHZUZkm)**
(click a status pill to move a ticket) for the live plan. The
**[Control Tower Blueprint](https://claude.ai/artifact/Lhw6uW284zYTB8J13tep6g)**
diagram shows the enterprise target state that `advanced/` grows into.

## Why no Organization

A Gmail-based GCP account has no Organization node — no folders, no
org-wide policies. Rather than pretend otherwise, this repo's default path
creates plain standalone projects (`folder_id` and `org_id` both default to
`null` everywhere, which is exactly what a project you'd create by hand in
the console looks like). If you register a domain later and set up Cloud
Identity Free ($0, just the domain costs money), `0-bootstrap` and the
`advanced/1-organization` stage are ready to bring things under real org
governance — see `advanced/README.md`.

## Layout

```
terragrunt.hcl      root Terragrunt config: shared GCS backend + provider generation
0-bootstrap/         seed project (no org parent), Terraform state bucket, GitHub OIDC (WIF)
                      — plain Terraform, not Terragrunt (see "Terraform vs Terragrunt" below)
1-networking/        ONE project, ONE VPC (2 subnets), Cloud NAT, firewall baseline — Phase 1/2
                      — Terragrunt unit (has terragrunt.hcl)
modules/             reusable building blocks used by every stage
tests/connectivity/  proves the network in 1-networking actually works before you build on it
                      — Terragrunt unit, depends on 1-networking's outputs
environments/        shared tfvars/hcl (billing account, region, state bucket)
.github/workflows/  CI: terragrunt plan on PR, terragrunt run-all apply on merge
diagrams/            source for the architecture/roadmap/backlog artifacts

advanced/          the original enterprise-shaped stages, set aside until
                    their tickets come up (see advanced/README.md) — still
                    plain Terraform, not yet converted to Terragrunt:
  1-organization/          folders + org policies — needs a real Organization
  2-networking-hub-spoke/  multi-VPC, Network Connectivity Center — ticket NET-5
  3-projects/              Shared VPC service projects — ticket NET-5
  4-gke/                   one private GKE cluster per environment — ticket GKE-5
  5-ai-apps/               Vertex AI notebook + Cloud Run — AI epic
```

### Terraform vs Terragrunt

`1-networking` and `tests/connectivity` run under **Terragrunt** now — it
removes two things that were getting repetitive: the hand-written `backend
"gcs" { prefix = "..." }` block in every stage (the root `terragrunt.hcl`
generates it, keyed off each stage's own directory path), and
`tests/connectivity`'s manual `data "terraform_remote_state"` block, now a
`dependency` block that reads `1-networking`'s outputs directly and makes
`terragrunt run-all apply` apply things in the right order automatically.

`0-bootstrap` stays plain Terraform on purpose — it's the stage that
*creates* the GCS bucket Terragrunt's remote_state block points at, so it
can't depend on that bucket already existing. `advanced/` stays plain
Terraform too, simply because nothing's converted it yet; the pattern
established in `1-networking/terragrunt.hcl` and
`tests/connectivity/terragrunt.hcl` is what that conversion will follow
when those tickets come up.

`1-networking` reuses the same `modules/vpc-spoke` and
`modules/firewall-baseline` that `advanced/2-networking-hub-spoke` uses for
each spoke — it's the same VPC shape, just one of them instead of several,
and not yet wired to a Network Connectivity Center hub. Leveling up later
(NET-5) is mostly "add a second VPC and a hub," not a rewrite.

## Prerequisites

- A GCP **billing account** you can attach a project to
  (`gcloud billing accounts list`)
- `terraform` >= 1.7 (or OpenTofu — both work), `terragrunt` >= 0.68
  ([install docs](https://terragrunt.gruntwork.io/docs/getting-started/install/)),
  `gcloud` (authenticated: `gcloud auth login` and
  `gcloud auth application-default login`)
- A GitHub repository to push this into, for the CI/CD pipeline —
  Workload Identity Federation is scoped to a specific `owner/repo`

**Cost warning**: this creates real billable resources — a Cloud NAT
gateway and a connectivity-test VM at minimum. Nothing here is
free-tier-only, though Phase 1 is close to it (a few dollars a month at
most if left running; near $0 if you destroy the probe VM after each
session — see `tests/connectivity/README.md`).

## Getting started

```bash
# 1. Bootstrap (run once, by hand, with your own gcloud credentials)
cd 0-bootstrap
cp terraform.tfvars.example terraform.tfvars   # fill in billing_account, github_repository (leave org_id unset)
terraform init
terraform apply

# grab these two outputs — you'll need them everywhere else
terraform output -raw terraform_state_bucket
terraform output -raw workload_identity_provider
terraform output -raw ci_service_account_email
```

Then:

1. Uncomment the `backend "gcs"` block in `0-bootstrap/versions.tf`, put the
   state bucket name in it, and run `terraform init -migrate-state` so
   bootstrap's own state moves off your laptop and into the bucket it just
   created.
2. Copy `environments/common.hcl.example` to `environments/common.hcl` and
   fill in `billing_account`, `state_bucket`, `region` (this is what
   Terragrunt reads; `environments/common.tfvars.example` still exists too,
   for the plain-Terraform stages — keep both in sync by hand).
3. Push this repo to GitHub. In the repo's Settings → Secrets and
   variables → Actions **Secrets** tab, add: `GCP_BILLING_ACCOUNT`,
   `TF_STATE_BUCKET`, `WIF_PROVIDER` (the `workload_identity_provider`
   output), `WIF_SERVICE_ACCOUNT` (the `ci_service_account_email` output).
   Optionally, in the **Variables** tab, add `GCP_REGION` if you're not
   using `africa-south1` (CI defaults to it otherwise). In Settings →
   Environments, create `shared-infra` — `terragrunt-apply.yml` deploys
   through it, which is where you'd add required reviewers later if you
   want a manual gate before anything applies to real infrastructure.
4. Open a PR touching `1-networking/` or `tests/connectivity/` —
   `terragrunt-plan.yml` runs `terragrunt validate` + `terragrunt plan` for
   each changed stage and comments the plan on the PR. Merge it —
   `terragrunt-apply.yml` runs `terragrunt run-all apply` from the repo
   root, which applies `1-networking` then `tests/connectivity` in that
   order automatically (dependency-ordered, same as running it locally).

Or run it locally with Terragrunt:

```bash
cd 1-networking
terragrunt apply
```

That's it — no `-backend-config`, no `-var-file`: `terragrunt.hcl` (via the
root config) already knows the state bucket, the prefix, the provider, and
`billing_account`/`region` from `environments/common.hcl`.

5. **Prove the network** (tickets NET-2, NET-4):
   ```bash
   cd tests/connectivity
   terragrunt apply
   ./run_connectivity_tests.sh
   terragrunt destroy   # clean up the probe VM when done
   ```
   `terragrunt apply` here pulls `project_id` and `subnet_self_link`
   straight from `1-networking`'s state via the `dependency` block in
   `tests/connectivity/terragrunt.hcl` — if you haven't applied
   `1-networking` yet, this will apply it first.

Or, from the repo root, apply everything that's wired into Terragrunt in
one go, in dependency order:

```bash
terragrunt run-all apply
```

**CI note:** `.github/workflows/terragrunt-plan.yml` and
`terragrunt-apply.yml` now run `terragrunt` directly, matrixed over
`1-networking` and `tests/connectivity` for plan, and `run-all apply` (or a
single stage via `workflow_dispatch`) for apply — the same commands as the
"Or run it locally" steps above, not a separate CI-only path. The one
CI-specific step is writing `environments/common.hcl` from the repo's
GitHub secrets at the start of each run, since that file is gitignored and
never committed. Nothing under `advanced/` is wired into CI — those stages
are still plain Terraform, apply them locally.

That's Phase 1 (Foundation) and the start of Phase 2 (Networking) done.
Everything past that — GKE, Security, Observability, AI/ML, and the
hub-and-spoke level-up — is tracked ticket by ticket in the
[backlog board](https://claude.ai/artifact/SNmXBAGFQK6oKwhGHZUZkm); nothing
past `1-networking` is built yet.

## Repo hygiene

`*.tfvars`/`common.hcl` (except the `.example` files) and all
`.terraform/`/`.terragrunt-cache/` directories are gitignored — never commit
`billing_account` or state files. `.terraform.lock.hcl` in each stage
*should* be committed once generated, for reproducible provider versions.
`terragrunt_generated_backend.tf` and `terragrunt_generated_provider.tf` are
also gitignored — Terragrunt rewrites them from `terragrunt.hcl` on every
`init`, so committing them would just be a stale copy that drifts.
