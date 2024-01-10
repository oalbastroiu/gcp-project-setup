locals {
  # manager_group_iam_roles is a list of GCP IAM roles required for
  # the members of manager_group to have the privileges allowing
  # execution of the bootstrapping step as users, without the
  # Terraform service account impersionation.
  manager_group_iam_roles = [
    "roles/iam.serviceAccountAdmin",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/storage.admin",
  ]

  # project_services is a list of GCP services to be enabled
  # in every bootstrapped project by default.
  project_services = [
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "storage-component.googleapis.com",
  ]

  # terraform_service_account_iam_roles is a list of GCP IAM roles
  # required for the Terraform IaC service account to have the privileges
  # allowing management of the GCP project and resources.
  terraform_service_account_iam_roles = [
    "roles/compute.networkAdmin",
    "roles/compute.securityAdmin",
    "roles/storage.admin",
    "roles/storage.objectAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.securityAdmin",
    "roles/iam.roleAdmin",
    "roles/serviceusage.serviceUsageAdmin",
  ]

  # identity_service_account_iam_roles is a list of GCP IAM roles
  # required for the identity service account to have the privileges
  # allowing management of the GCP project networking.
  identity_service_account_iam_roles = [
    "roles/servicenetworking.serviceAgent",
  ]

  # manager_group_service_account_iam_roles is a list of GCP IAM roles
  # required for the management group to impersonate the Terraform IaC
  # service account allowing management of the GCP project and resources.
  manager_group_service_account_iam_roles = [
    "roles/iam.serviceAccountTokenCreator",
  ]
}
