variable "gcp_service_list" {
  description            = "The list of apis necessary to implement the use case"
  type                   = list(string)
  default                = [
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ]
}

resource "google_project_service" "gcp_services" {
  for_each               = toset(var.gcp_service_list)
  project                = var.gcp_project_id
  service                = each.key
  disable_dependent_services = true
}

resource "google_artifact_registry_repository" "docker-main" {
  location               = var.gcp_region
  repository_id          = var.repository_id
  description            = "Main Docker Repository for Cloud Run"
  format                 = "DOCKER"
  depends_on = [ 
    google_project_service.gcp_services
  ]
}
