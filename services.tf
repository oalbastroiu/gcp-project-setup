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
        # 2. Enable vpcaccess.googleapis.com if one network requires it
        [for r in keys(var.vpc_regions) : "vpcaccess.googleapis.com" if var.vpc_regions[r].vpcaccess],
        # 3. All services provided by the user
        var.enabled_services
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
