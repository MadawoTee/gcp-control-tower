# Connectivity tests

Verifies that stage `1-networking`'s dev VPC actually works, end to end,
before you build anything on top of it (GKE, AI apps, etc).

## What it checks

1. **Internal DNS resolution** — the probe can resolve
   `metadata.google.internal`, confirming Google's internal DNS is reachable.
2. **Cloud NAT egress** — the probe has *no external IP*, yet can still
   reach `https://www.google.com`, proving the Cloud NAT gateway created in
   `modules/vpc-spoke` is doing its job.

There's only one VPC at this stage, so there's no cross-VPC reachability
check yet — that's ticket NET-5, once `advanced/2-networking-hub-spoke`
wires up a second VPC and Network Connectivity Center.

## Running it

This is a Terragrunt unit — its `terragrunt.hcl` has a `dependency` block on
`1-networking`, so `terragrunt apply` here applies `1-networking` first if
it hasn't been already, and wires `project_id`/`subnet_self_link` straight
from its outputs:

```bash
cd tests/connectivity
terragrunt apply
./run_connectivity_tests.sh
```

(Plain Terraform still works if you'd rather not use Terragrunt here — pass
`project_id` and `subnet_self_link` yourself: `terraform init
-backend-config="bucket=<...>" -backend-config="prefix=tests/connectivity"`
then `terraform apply -var="project_id=<...>"
-var="subnet_self_link=<...>"`, using `1-networking`'s own outputs.)

Requires `gcloud` to be authenticated as a principal with
`roles/iap.tunnelResourceAccessor` and `roles/compute.osLogin` (or
equivalent) on the dev project — the same access you'd need to SSH into any
private GCE instance via IAP.

## Cleaning up

The probe VM costs a few cents an hour (e2-micro) — destroy it when you're
done testing a given change:

```bash
terragrunt destroy
```

## Extending (NET-5 and later)

Once `advanced/2-networking-hub-spoke` is converted to Terragrunt too, add
a second `dependency` block here (or a second probe VM per spoke) and bring
back the cross-VPC ping loop — the previous version of this test suite
(the `data "terraform_remote_state"` version, before the Terragrunt rework)
is preserved in git history if you want the starting point.
