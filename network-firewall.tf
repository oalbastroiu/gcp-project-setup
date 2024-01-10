resource "google_compute_firewall" "allow-all-internal" {
  provider = google
  count    = var.skip_default_vpc_creation ? 0 : 1

  name        = "fw-allow-all-internal"
  description = "Allows all traffic from inside VPC"
  network     = google_compute_network.default[0].name
  project     = data.google_project.project.project_id

  allow {
    protocol = "all"
  }

  source_ranges = local.default_vpc_active_ranges
}

resource "google_compute_firewall" "allow-ssh-iap" {
  provider = google
  count    = var.skip_default_vpc_creation ? 0 : 1

  name        = "fw-allow-ssh-iap"
  description = "Allows SSH traffic from all known IP Addresses used by Cloud Identity-Aware Proxy"
  network     = google_compute_network.default[0].name
  project     = data.google_project.project.project_id

  allow {
    protocol = "tcp"
    ports    = [22]
  }

  target_tags = [
    "fw-allow-ssh-iap",
  ]

  source_ranges = data.google_netblock_ip_ranges.iap-forwarders.cidr_blocks
}

resource "google_compute_firewall" "allow-all-iap" {
  provider = google
  count    = var.skip_default_vpc_creation ? 0 : 1

  name        = "fw-allow-all-iap"
  description = "Allows ALL traffic from all known IP Addresses used by Cloud Identity-Aware Proxy"
  network     = google_compute_network.default[0].name
  project     = data.google_project.project.project_id

  allow {
    protocol = "all"
  }

  target_tags = [
    "fw-allow-all-iap",
  ]

  source_ranges = data.google_netblock_ip_ranges.iap-forwarders.cidr_blocks
}
