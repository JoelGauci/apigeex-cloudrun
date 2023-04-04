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

variable "url_mask" {
  type        = string
  description = "URL mask of the serverless network endpoint group (neg)."
}

variable "apigee_endpoint_attachment" {
  type        = string
  description = "Apigee endpoint attachment value."
}
