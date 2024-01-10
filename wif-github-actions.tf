resource "google_iam_workload_identity_pool" "github-actions" {
  provider = google
  count    = local.github_actions_enabled
  project  = data.google_project.project.project_id

  workload_identity_pool_id = "github-actions"
  display_name              = "Github actions"
  description               = "Identity pool github actions pipelines"

  depends_on = [
    google_project_iam_binding.roles,
    google_project_service.wif
  ]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  provider = google
  count    = local.github_actions_enabled
  project  = data.google_project.project.project_id

  workload_identity_pool_id          = google_iam_workload_identity_pool.github-actions[0].workload_identity_pool_id
  workload_identity_pool_provider_id = "github"
  display_name                       = "GitHub"
  description                        = "OIDC Identity Pool Provider for GitHub Actions pipelines"

  attribute_mapping = var.workload_identity_pool_attribute_mapping

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  depends_on = [
    google_iam_workload_identity_pool.github-actions
  ]
}
