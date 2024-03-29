variable "project_id" {
  description = "GCP project ID"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,30}[a-z0-9]", var.project_id))
    error_message = "The ID of the project. It must be 6 to 30 lowercase letters, digits, or hyphens."
  }
}

variable "enabled_services" {
  description = <<-EOD
    List of GCP enabled services / APIs to enable. Dependencies will be enabled automatically.

    **Remark**: Google sometimes changes (mostly adding) dependencies and will activate those automatically for your
    project. Therefore being authoritative on services usually causes a lot of trouble. The module doesn't provide any
    option to be authoritative for this reason. By default we are partly authoritative. This can can be controlled
    by the `enabled_services_disable_on_destroy` flag.

    Example:
    ```
    enabled_services = [
      "bigquery.googleapis.com",
      "compute.googleapis.com",
      "cloudscheduler.googleapis.com",
      "iap.googleapis.com"
    ]
    ```
  EOD
  type        = list(string)
  default     = []
}

variable "enabled_services_disable_on_destroy" {
  description = <<-EOD
    If true, try to disable a service given via `enabled_services` after its removal from from the list.
    Defaults to true. May be useful in the event that a project is long-lived but the infrastructure running in
    that project changes frequently.

    Can result in failing terraform runs if the removed service is a dependency for any other active service.
  EOD
  type        = bool
  default     = true
}

/*
/**************************************************************************************************/
/*                                                                                                */
/* IAM                                                                                            */
/*                                                                                                */
/**************************************************************************************************/
variable "roles" {
  description = <<-EOD
    IAM roles and their members.

    If you create a service account in this project via the `service_accounts` input, we recommend
    to use the `project_roles` attribute of the respective service account to grant it permissions
    on the project's IAM policy. This allows you to better re-use your code in staged environments.

    Example:
    ```
    roles = {
      "roles/bigquery.admin" = [
        "group:customer.project-role@educated-app-devel.iam.gserviceaccount.com"
      ],
      "roles/cloudsql.admin" = [
        "group:customer.project-role@educated-app-devel.iam.gserviceaccount.com",
      ]
    }
    ```
  EOD

  type = map(list(string))
}

variable "deprivilege_compute_engine_sa" {
  description = <<-EOD
    By default the compute engine service account (*project-number*-compute@developer.gserviceaccount.com) is assigned `roles/editor`
    If you want to deprivilege the account set this to true, and grant needed permissions via roles variable.
    Otherwise the module will grant `roles/editor` to the service account.
  EOD

  type    = bool
  default = false
}

variable "custom_roles" {
  description = <<-EOD
    Create custom roles and define who gains that role on project level

    Example:
    ```
    custom_roles = {
      "appengine.applicationsCreator" = {
        title       = "AppEngine Creator",
        description = "Custom role to grant permissions for creating App Engine applications.",
        permissions = [
          "appengine.applications.create",
        ]
        members = [
          "group:customer.project-role@educated-app-devel.iam.gserviceaccount.com",
        ]
      }
    }
    ```
  EOD

  type = map(object({
    title       = string
    description = string
    permissions = list(string)
    members     = list(string)
  }))

  default = {}
}

variable "service_accounts" {
  description = <<-EOD
    Service accounts to create for this project.

    **`display_name`:** Human-readable name shown in Google Cloud Console

    **`description` (optional):** Human-readable description shown in Google Cloud Console

    **`iam` (optional):** IAM permissions assigned to this Service Account as a *resource*. This defines which principal
    can do something on this Service Account. An example: If you grant `roles/iam.serviceAccountKeyAdmin` to a group
    here, this group will be able to maintain Service Account keys for this specific SA. If you want to allow this SA to
    use BigQuery, you need to use the project-wide `roles` input or, even better, use the `project_roles` attribute to
    do so.

    **`project_roles` (optional):** IAM permissions assigned to this Service Account on *project level*.
    This parameter is merged with whatever is provided as the project's IAM policy via the `roles` input.

    **`iam_non_authoritative_roles` (optional):** Any role given in this list will be added to the authoritative policy
    with its current value as defined in the Google Cloud Platform. Example use case: Composer 2 adds values to
    `roles/iam.workloadIdentityUser` binding when an environment is created or updated. Thus, you might want to
    automatically import those permissions.

    **`github_action_repositories` (optional):** You can list GitHub repositories (format: `user/repo`) here.
    A Workload Identity Pool and a Workload Identity Provider needed for Workload Identity Federation will be
    created automatically. Each repository given gains permissions to authenticate as this service account using
    Workload Identity Federation. This allows any GitHub Action pipeline to use this service account without the need
    for service account keys. An example can be found within the [FAQ].

    For more details, see the documentation for Google's GitHub action for authentication:
    [`google-github-actions/auth`](https://github.com/google-github-actions/auth).

    **Remark:** If you configure `github_action_repositories`, the module binds a member for each repository to the role
    `roles/iam.workloadIdentityUser` inside the service account's IAM policy. This is done *regardless of whether
    or not* you list this role in the `iam_non_authoritative_roles` key. The same happens if you use
    `runtime_service_accounts`. A member per runtime service account is added to the service account's IAM policy.

    **Remark:** You need to grant the role `roles/iam.workloadIdentityPoolAdmin` to the principal that is
    executing the terraform code (most likely a service account used in a pipeline) if you plan to use
    `github_action_repositories` or `runtime_service_accounts`.

    Example:
    ```
        deployments = {
          display_name  = "Deployments"
          description   = "Service Account to deploy application"

          # Grant this service account Cloud Run Admin on project level
          project_roles = [
            "roles/run.admin"
          ]

          # Allow specific group to create keys for this Service Account only
          iam = {
            "roles/iam.serviceAccountKeyAdmin" = [
              "group:customer.project-role@educated-app-devel.iam.gserviceaccount.com",
            ]
          }

          # This service account will be used by GitHub Action deployments in the given repository
          github_action_repositories = [
            "my-user-or-organisation/my-great-repo"
          ]
        }
        bq-reader = {
          display_name = "BigQuery Reader"
          description  = "Service Account for BigQuery Reader for App XYZ"
          iam          = {} # No special Service Account resource IAM permissions
        }
      }
    }
    ```
  EOD

  type = map(object({
    display_name                = string
    description                 = optional(string)
    iam                         = map(list(string))
    project_roles               = optional(list(string))
    iam_non_authoritative_roles = optional(list(string))
    github_action_repositories  = optional(list(string))
  }))

  default = {}
}

variable "non_authoritative_roles" {
  description = <<-EOD
    List of roles (regex) to exclude from authoritative project IAM handling.
    Roles listed here can have bindings outside of this module.

    Example:
    ```
    non_authoritative_roles = [
      "roles/container.hostServiceAgentUser"
    ]
    ```
  EOD
  type        = list(string)
  default     = []
}

variable "essential_contacts" {
  description = <<-EOD
    Essential contacts receive configurable notifications from Google Cloud Platform
    based on selected categories.

    **`language`:** The preferred language for notifications, as an ISO 639-1 language code.
    See [documentation](https://cloud.google.com/resource-manager/docs/managing-notification-contacts#supported-languages)
    for a list of supported languages.

    **`categories`:** The categories of notifications that the contact will receive communications for.
    See [documentation](https://cloud.google.com/resource-manager/docs/managing-notification-contacts#notification-categories)
    for a list of supported categories.

    **Remark:** The module will enable the essential contacts API automatically once one contact is configured.
    You still need to grant the role `roles/essentialcontacts.admin` to the principle that is executing
    the terraform code (most likely your service account used in your pipeline) if you plan to use
    `github_action_repositories`.

    ```
    EOD
  type = map(object({
    language   = string
    categories = list(string)
  }))
  default = {}
}

variable "workload_identity_pool_attribute_mapping" {
  description = <<-EOD
    Maps attributes from authentication credentials issued by an external identity provider
    to Google Cloud attributes

    **Note** Teams must be cautious before modifying the attribute mapping as it may cause
    undesired permission issues. See [documentation](https://cloud.google.com/iam/docs/configuring-workload-identity-federation#github-actions)
    Example:
    ```
    {
      "google.subject"             = "assertion.sub"
      "attribute.actor"            = "assertion.actor"
      "attribute.aud"              = "assertion.aud"
      "attribute.repository"       = "assertion.repository"
      "attribute.repository_owner" = "assertion.repository_owner"
    }
    ```

  EOD
  type        = map(any)
  default = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }
}
