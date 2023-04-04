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

variable "consumer_vpc" {
  type        = string
  description = "Consumer VPC network name."
}

variable "endpoint_attachment_ipaddress" {
  type        = string
  description = "IP address of the endpoint attachment on Apigee"
}

