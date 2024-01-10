# Get project ID details based on project ID
data "google_project" "project" {
  provider   = google
  project_id = var.project_id
}

# Fetch needed CIDR blocks from google for firewall rules and similar
data "google_netblock_ip_ranges" "iap-forwarders" {
  provider   = google
  range_type = "iap-forwarders"
}

data "google_client_config" "current" {
}

# active IAM roles
data "external" "active-roles" {
  program = ["bash", "${path.module}/get-active-roles-project-iam.sh"]
  query = {
    project_id   = data.google_project.project.project_id
    access_token = data.google_client_config.current.access_token
  }
}

locals {
  role_excludes = compact(concat(
    var.non_authoritative_roles,
    [
      # See: https://cloud.google.com/iam/docs/service-agents
      "\\.serviceAgent$",
      "\\.ServiceAgent$",
      "^roles/cloudbuild.builds.builder$",
      "^roles/securitycenter.notificationServiceAgent$",
      "^roles/monitoring.notificationServiceAgent$",
      "^roles/firebaserules.system$",
      "^roles/container.nodeServiceAgent$"
    ]
  ))

  # Split the list of active roles from the external data source
  active_roles_splitted = split(",", data.external.active-roles.result.roles)
  # exclude all project or org level custom roles
  active_roles_no_custom = [for role in local.active_roles_splitted : role if can(regex("^roles/", role))]
  # get a list of active roles we need to exclude (assigned to service accounts automatically and similar)
  active_roles_to_exclude = compact(flatten([
    for role in local.active_roles_no_custom : [
      for exclude in local.role_excludes : role if can(regex(exclude, role))
    ]
  ]))
  # remove the roles to exclude from the active roles
  active_roles = tolist(setsubtract(local.active_roles_no_custom, local.active_roles_to_exclude))
}
