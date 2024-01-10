terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.78.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 4.78.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
  }
  required_version = ">= 1.5.0"
}
