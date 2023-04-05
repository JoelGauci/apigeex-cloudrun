output "service_urls" {
  description = "Cloud Run service URLs"
  value       = values(module.cloud_run)[*].service_url
}

output "instance_endpoint_host" {
  description = "Internal runtime endpoint IP address"
  value = google_apigee_endpoint_attachment.endpoint_attachment.host
}