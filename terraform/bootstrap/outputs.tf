# Bootstrap Outputs
# 
# These outputs provide the values needed to configure GitHub Actions secrets and variables.

output "subscription_id" {
  description = "Azure Subscription ID"
  value       = data.azurerm_subscription.current.subscription_id
}

output "tenant_id" {
  description = "Azure AD Tenant ID"
  value       = data.azurerm_client_config.current.tenant_id
}

output "client_id" {
  description = "Azure AD Application (Client) ID for GitHub Actions"
  value       = azuread_application.github_actions.client_id
}

output "service_principal_object_id" {
  description = "Service Principal Object ID"
  value       = azuread_service_principal.github_actions.object_id
}

# Terraform State Storage
output "terraform_state_resource_group" {
  description = "Resource group name for Terraform state storage"
  value       = azurerm_resource_group.terraform_state.name
}

output "terraform_state_storage_account" {
  description = "Storage account name for Terraform state"
  value       = azurerm_storage_account.terraform_state.name
}

output "terraform_state_container" {
  description = "Storage container name for Terraform state"
  value       = azurerm_storage_container.terraform_state.name
}

# GitHub Configuration Summary
output "github_secrets_configuration" {
  description = "Summary of GitHub secrets to configure"
  value = <<-EOT

    ============================================================
    GitHub Repository Secrets Configuration
    ============================================================
    
    Configure the following SECRETS in your GitHub repository:
    Settings -> Secrets and variables -> Actions -> Secrets
    
    For environment: ${var.environment}
    
    AZURE_CLIENT_ID:       ${azuread_application.github_actions.client_id}
    AZURE_TENANT_ID:       ${data.azurerm_client_config.current.tenant_id}
    AZURE_SUBSCRIPTION_ID: ${data.azurerm_subscription.current.subscription_id}
    
    ============================================================
    GitHub Repository Variables Configuration
    ============================================================
    
    Configure the following VARIABLES in your GitHub repository:
    Settings -> Secrets and variables -> Actions -> Variables
    
    TF_STATE_RESOURCE_GROUP:  ${azurerm_resource_group.terraform_state.name}
    TF_STATE_STORAGE_ACCOUNT: ${azurerm_storage_account.terraform_state.name}
    TF_STATE_CONTAINER:       ${azurerm_storage_container.terraform_state.name}
    
    ============================================================
    GitHub Environment Configuration
    ============================================================
    
    Create a GitHub Environment named: ${var.environment}
    Settings -> Environments -> New environment
    
    Add the same secrets and variables to the environment for 
    environment-specific deployments.
    
    ============================================================
    
  EOT
}

# GitHub CLI Commands for setup
output "github_cli_commands" {
  description = "GitHub CLI commands to configure secrets and variables"
  value = <<-EOT

    # GitHub CLI commands to configure repository secrets and variables
    # Run these commands from your repository root
    
    # Set repository secrets
    gh secret set AZURE_CLIENT_ID --body "${azuread_application.github_actions.client_id}"
    gh secret set AZURE_TENANT_ID --body "${data.azurerm_client_config.current.tenant_id}"
    gh secret set AZURE_SUBSCRIPTION_ID --body "${data.azurerm_subscription.current.subscription_id}"
    
    # Set repository variables
    gh variable set TF_STATE_RESOURCE_GROUP --body "${azurerm_resource_group.terraform_state.name}"
    gh variable set TF_STATE_STORAGE_ACCOUNT --body "${azurerm_storage_account.terraform_state.name}"
    gh variable set TF_STATE_CONTAINER --body "${azurerm_storage_container.terraform_state.name}"
    
    # Create GitHub environment (if using environment-specific deployments)
    gh api repos/{owner}/{repo}/environments/${var.environment} --method PUT
    
    # Set environment-specific secrets (optional, for multi-environment setups)
    gh secret set AZURE_CLIENT_ID --env ${var.environment} --body "${azuread_application.github_actions.client_id}"
    gh secret set AZURE_TENANT_ID --env ${var.environment} --body "${data.azurerm_client_config.current.tenant_id}"
    gh secret set AZURE_SUBSCRIPTION_ID --env ${var.environment} --body "${data.azurerm_subscription.current.subscription_id}"
    
  EOT
}
