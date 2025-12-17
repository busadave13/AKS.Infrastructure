# Bootstrap Configuration for GitHub OIDC/Workload Identity
# 
# This configuration creates the necessary Azure AD resources for 
# GitHub Actions to authenticate to Azure using OIDC (Workload Identity).
#
# Run this configuration ONCE to set up:
# 1. Azure AD Application Registration
# 2. Service Principal
# 3. Federated Credentials for GitHub Actions
# 4. Azure Storage Account for Terraform state
# 5. Required role assignments
#
# Prerequisites:
# - Azure CLI authenticated with sufficient permissions
# - Permissions to create Azure AD applications
# - Contributor or Owner role on the subscription

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.14"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "azuread" {}

# Data sources
data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}
data "azuread_client_config" "current" {}

# Random suffix for globally unique names
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Local variables
locals {
  resource_group_name    = "rg-terraform-state-${var.environment}"
  storage_account_name   = "stterraform${random_string.suffix.result}"
  container_name         = "tfstate"
  app_name               = "sp-github-actions-${var.github_repository_name}-${var.environment}"
  
  # GitHub OIDC issuer
  github_issuer = "https://token.actions.githubusercontent.com"
  
  # Common tags
  tags = {
    Environment = var.environment
    Purpose     = "terraform-state"
    ManagedBy   = "terraform-bootstrap"
    Repository  = var.github_repository
  }
}

# =============================================================================
# Azure AD Application and Service Principal
# =============================================================================

resource "azuread_application" "github_actions" {
  display_name = local.app_name
  owners       = [data.azuread_client_config.current.object_id]

  tags = ["GitHub Actions", "OIDC", var.environment]
}

resource "azuread_service_principal" "github_actions" {
  client_id                    = azuread_application.github_actions.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]

  tags = ["GitHub Actions", "OIDC", var.environment]
}

# =============================================================================
# Federated Identity Credentials for GitHub Actions
# =============================================================================

# Federated credential for pull requests
resource "azuread_application_federated_identity_credential" "github_pr" {
  application_id = azuread_application.github_actions.id
  display_name   = "github-pr-${var.environment}"
  description    = "GitHub Actions - Pull Requests"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = local.github_issuer
  subject        = "repo:${var.github_repository}:pull_request"
}

# Federated credential for main branch
resource "azuread_application_federated_identity_credential" "github_main" {
  application_id = azuread_application.github_actions.id
  display_name   = "github-main-${var.environment}"
  description    = "GitHub Actions - Main Branch"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = local.github_issuer
  subject        = "repo:${var.github_repository}:ref:refs/heads/main"
}

# Federated credential for GitHub environment
resource "azuread_application_federated_identity_credential" "github_environment" {
  application_id = azuread_application.github_actions.id
  display_name   = "github-env-${var.environment}"
  description    = "GitHub Actions - Environment ${var.environment}"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = local.github_issuer
  subject        = "repo:${var.github_repository}:environment:${var.environment}"
}

# =============================================================================
# Role Assignments
# =============================================================================

# Contributor role on the subscription for Terraform deployments
resource "azurerm_role_assignment" "github_actions_contributor" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.github_actions.object_id
}

# User Access Administrator for managing RBAC (optional, enable if needed)
resource "azurerm_role_assignment" "github_actions_uaa" {
  count                = var.enable_rbac_management ? 1 : 0
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "User Access Administrator"
  principal_id         = azuread_service_principal.github_actions.object_id
}

# =============================================================================
# Terraform State Storage
# =============================================================================

resource "azurerm_resource_group" "terraform_state" {
  name     = local.resource_group_name
  location = var.location

  tags = local.tags
}

resource "azurerm_storage_account" "terraform_state" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.terraform_state.name
  location                 = azurerm_resource_group.terraform_state.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  # Security settings
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false  # Disable shared key access, use Azure AD
  
  blob_properties {
    versioning_enabled = true
    
    delete_retention_policy {
      days = 30
    }
    
    container_delete_retention_policy {
      days = 30
    }
  }

  tags = local.tags
}

resource "azurerm_storage_container" "terraform_state" {
  name                  = local.container_name
  storage_account_id    = azurerm_storage_account.terraform_state.id
  container_access_type = "private"
}

# Storage Blob Data Contributor role for the service principal
resource "azurerm_role_assignment" "storage_blob_contributor" {
  scope                = azurerm_storage_account.terraform_state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.github_actions.object_id
}

# Storage Blob Data Contributor role for the current user (for local development)
resource "azurerm_role_assignment" "storage_blob_contributor_current_user" {
  scope                = azurerm_storage_account.terraform_state.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
}
