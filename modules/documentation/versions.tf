terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = ">= 2.5"
    }
  }
  required_version = ">= 1.9"
}
