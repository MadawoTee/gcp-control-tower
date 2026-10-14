variable "project_id" { type = string }
variable "region" { type = string }
variable "zone" { type = string }
variable "network_self_link" { type = string }
variable "subnetwork_self_link" { type = string }

variable "create_notebook" {
  type    = bool
  default = true
}
variable "notebook_name" {
  type    = string
  default = "ai-lab-notebook"
}
variable "notebook_machine_type" {
  type    = string
  default = "e2-standard-4"
}

variable "create_cloud_run_service" {
  type    = bool
  default = false
}
variable "app_name" {
  type    = string
  default = "ai-app"
}
variable "container_image" {
  description = "Container image for the Cloud Run AI app, e.g. us-docker.pkg.dev/PROJECT/repo/ai-app:latest"
  type        = string
  default     = "gcr.io/cloudrun/hello"
}
variable "serverless_connector_cidr" {
  description = "/28 CIDR for the Serverless VPC Access connector"
  type        = string
  default     = "10.9.0.0/28"
}
variable "cloud_run_service_account_email" {
  description = "Service account the Cloud Run service runs as (least-privilege, scoped to Vertex AI access)"
  type        = string
  default     = null
}
