# Terraform version constraints and required providers
# This file is shared across all environments

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.52.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = "~> 1.10.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
}
