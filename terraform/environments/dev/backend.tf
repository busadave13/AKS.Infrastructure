# Terraform Backend Configuration
# 
# This backend uses OIDC/Workload Identity authentication via GitHub Actions.
# No secrets required - authentication is handled via federated credentials.
#
# Prerequisites:
# 1. Run the bootstrap configuration: terraform/bootstrap/
# 2. Configure GitHub secrets and variables as shown in bootstrap outputs
#
# The backend is configured via -backend-config flags in the GitHub Actions workflow,
# allowing dynamic configuration and OIDC authentication.

terraform {
  backend "azurerm" {
    # Configuration provided at init time via GitHub Actions workflow:
    # -backend-config="resource_group_name=..."
    # -backend-config="storage_account_name=..."
    # -backend-config="container_name=tfstate"
    # -backend-config="key=dev.terraform.tfstate"
    # -backend-config="use_oidc=true"
  }
}
