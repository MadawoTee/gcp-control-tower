/**
 * Stage 1: Networking (single VPC)
 * ==================================
 * Tickets NET-1 .. NET-4. One project, one VPC, two subnets (one of them
 * carrying secondary ranges GKE will use in Phase 3), Cloud NAT, and the
 * firewall baseline. No Organization, no folders, no hub-and-spoke — those
 * come later (NET-5, in advanced/) once this is solid and, if you want the
 * folder/org-policy pieces for real, once you've set up Cloud Identity.
 *
 * project-factory's folder_id defaults to null, so this project is created
 * as a plain standalone project — exactly what a personal GCP account
 * without an Organization needs.
 */

module "dev_project" {
  source = "../modules/project-factory"

  project_id_prefix   = var.project_id_prefix
  existing_project_id = var.existing_project_id
  billing_account     = var.billing_account
  environment         = "dev"
  enabled_apis = [
    "compute.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
  ]
}

module "dev_vpc" {
  source = "../modules/vpc-spoke"

  project_id   = module.dev_project.project_id
  network_name = var.network_name
  environment  = "dev"
  region       = var.region
  primary_cidr = var.primary_cidr

  gke_secondary_ranges = [
    { range_name = "pods", cidr = var.pods_cidr },
    { range_name = "services", cidr = var.services_cidr },
  ]
}

module "dev_firewall" {
  source = "../modules/firewall-baseline"

  project_id   = module.dev_project.project_id
  network_name = module.dev_vpc.network_name
  internal_cidr_ranges = [
    var.primary_cidr,
    var.pods_cidr,
    var.services_cidr,
  ]
}
