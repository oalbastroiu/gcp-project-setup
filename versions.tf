terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.29.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.29.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.3.1"
}
