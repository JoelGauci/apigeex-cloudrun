variable "gcp_service_list" {
  description            = "The list of apis necessary to implement the use case"
  type                   = list(string)
  default                = [
    "dns.googleapis.com",
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

resource "google_dns_managed_zone" "private-zone-apigee" {
  name                  = "private-zone-apigee"
  dns_name              = "example.com."
  description           = "ExCo private DNS zone (Apigee)"
  visibility            = "private"
  private_visibility_config {
    networks {
      network_url       = "projects/${var.gcp_project_id}/global/networks/${var.consumer_vpc}"
    }
  }
  depends_on = [ 
    google_project_service.gcp_services
  ]
}

resource "google_dns_managed_zone" "private-zone-ilb" {
  name                  = "private-zone-ilb"
  dns_name              = "example.com."
  description           = "ExCo private DNS zone (L7 ILB)"
  visibility            = "private"
  private_visibility_config {
    networks {
      network_url       = "projects/${var.gcp_project_id}/global/networks/l7-ilb-network"
    }
  }
  depends_on = [ 
    google_project_service.gcp_services
  ]
}

resource "google_dns_record_set" "a-apigee" {
  name                  = "internal.${google_dns_managed_zone.private-zone-apigee.dns_name}"
  managed_zone          = google_dns_managed_zone.private-zone-apigee.name
  type                  = "A"
  ttl                   = 300
  rrdatas               = [var.endpoint_attachment_ipaddress]
}

resource "google_dns_record_set" "a-ilb" {
  name                  = "internal.${google_dns_managed_zone.private-zone-ilb.dns_name}"
  managed_zone          = google_dns_managed_zone.private-zone-ilb.name
  type                  = "A"
  ttl                   = 300
  rrdatas               = ["10.0.1.5"]
}

resource "google_service_networking_peered_dns_domain" "apigee" {
  project               = var.gcp_project_id
  name                  = "apigee-dns-peering"
  network               = var.consumer_vpc
  dns_suffix            = google_dns_managed_zone.private-zone-apigee.dns_name
}
