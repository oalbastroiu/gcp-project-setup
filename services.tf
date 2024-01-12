locals {
  services = toset(
    distinct(
      concat(
        # 1. These base APIs should be enabled regardless of the usage of the
        # projectcfg module
        [
          "iam.googleapis.com",
          "compute.googleapis.com",
          "iap.googleapis.com",
          "servicenetworking.googleapis.com"
        ],
      )
    )
  )
}

resource "google_project_service" "project" {
  for_each = local.services

  project            = data.google_project.project.project_id
  service            = each.key
  disable_on_destroy = var.enabled_services_disable_on_destroy
}
