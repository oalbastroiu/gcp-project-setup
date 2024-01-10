output "project_id" {
  description = "GCP project ID"
  value       = data.google_project.project.project_id

  depends_on = [
    # external data sources
    data.external.active-roles,
    data.external.sa_non_authoritative_role_members,
    # iam project roles
    google_project_iam_binding.roles,
    google_project_iam_binding.custom_roles,
  ]
}

output "service_accounts" {
  description = "List of service accounts created"
  value = {
    for name, data in google_service_account.service_accounts : name => data.email
  }

  depends_on = [
    google_service_account.service_accounts
  ]
}