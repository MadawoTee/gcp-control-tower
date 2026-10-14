/**
 * Stage 5: AI Apps  (Phase 3)
 * =============================
 * Drops a Vertex AI Workbench notebook (and, optionally, a Cloud Run
 * service) into one environment's project/VPC. Point this at "dev" while
 * you're learning; duplicate the module block with a different
 * `ai_environment` once you want an AI workload sitting in its own VPC,
 * reachable from your GKE clusters through the same NCC hub.
 */

module "ai_app" {
  source = "../../modules/ai-app"

  project_id           = data.terraform_remote_state.projects.outputs.app_project_ids[var.ai_environment]
  region               = var.region
  zone                 = var.zone
  network_self_link    = data.terraform_remote_state.networking.outputs.env_vpc_self_links[var.ai_environment]
  subnetwork_self_link = data.terraform_remote_state.networking.outputs.env_subnet_self_links[var.ai_environment]

  create_cloud_run_service = var.create_cloud_run_service
  container_image          = var.container_image
}
