# Development Environment - Backend Configuration
# 
# To use remote state with Azure Storage, uncomment the backend block below
# and create the storage account first with:
#
# az group create -n rg-terraform-state -l eastus2
# az storage account create -n stterraformstate -g rg-terraform-state -l eastus2 --sku Standard_LRS
# az storage container create -n tfstate --account-name stterraformstate
#

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstate"
    container_name       = "tfstate"
    key                  = "aks-dev.terraform.tfstate"
  }
}

# For local development, use local state (default)
# When ready for production, enable remote state above
