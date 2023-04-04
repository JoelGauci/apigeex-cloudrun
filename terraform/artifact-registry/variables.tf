variable "gcp_project_id" {
  type        = string
  description = "The GCP project ID to create the gcp resources in."
}
 
variable "gcp_region" {
  type        = string
  description = "The GCP region to create the gcp resources in."
}
 
variable "gcp_zone" {
  type        = string
  description = "The GCP zone to create the gcp resources in."
}

variable "repository_id" {
  type        = string
  description = "Repository id of the artifact registry."
}
