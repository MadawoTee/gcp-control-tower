/**
 * ai-app  (Phase 3)
 * -------------------
 * Minimal scaffold for deploying an AI workload in its own project/VPC:
 *   - a Vertex AI Workbench instance for experimentation/notebooks
 *   - a Cloud Run service (serverless, VPC-connected via a Serverless VPC
 *     Access connector) to serve a model or call Vertex AI's predict API
 *
 * This intentionally stays small — swap the Cloud Run image for your own
 * once you have something to deploy, and add a Vertex AI endpoint /
 * GKE-based model serving (e.g. via the gke-private-cluster module) as you
 * go further.
 */

resource "google_workbench_instance" "notebook" {
  count    = var.create_notebook ? 1 : 0
  project  = var.project_id
  name     = var.notebook_name
  location = var.zone

  gce_setup {
    machine_type = var.notebook_machine_type

    network_interfaces {
      network  = var.network_self_link
      subnet   = var.subnetwork_self_link
      nic_type = "GVNIC"
    }

    disable_public_ip = true
  }
}

resource "google_vpc_access_connector" "serverless" {
  count         = var.create_cloud_run_service ? 1 : 0
  project       = var.project_id
  name          = "${var.app_name}-vpc-connector"
  region        = var.region
  ip_cidr_range = var.serverless_connector_cidr
  network       = var.network_self_link
}

resource "google_cloud_run_v2_service" "ai_app" {
  count    = var.create_cloud_run_service ? 1 : 0
  project  = var.project_id
  name     = var.app_name
  location = var.region

  template {
    containers {
      image = var.container_image

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      env {
        name  = "VERTEX_AI_PROJECT"
        value = var.project_id
      }
      env {
        name  = "VERTEX_AI_REGION"
        value = var.region
      }
    }

    vpc_access {
      connector = google_vpc_access_connector.serverless[0].id
      egress    = "PRIVATE_RANGES_ONLY"
    }

    service_account = var.cloud_run_service_account_email
  }

  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
}
