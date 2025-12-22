# Staging Environment - Backend Configuration
# 
# To use remote state with Azure Storage, uncomment the backend block below
# and create the storage account first with:
#
# az group create -n rg-terraform-state -l eastus2
# az storage account create -n stterraformstatewus3 -g rg-terraform-state -l westus3 --sku Standard_LRS
# az storage container create -n tfstate --account-name stterraformstatewus3
#

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstatewus3"
    container_name       = "tfstate"
    key                  = "aks-staging.terraform.tfstate"
  }
}

# For local development, use local state (default)
# When ready for production, enable remote state above
