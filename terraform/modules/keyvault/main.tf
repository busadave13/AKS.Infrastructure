# Key Vault Module
# Creates Azure Key Vault with private endpoint

#--------------------------------------------------------------
# Data Sources
#--------------------------------------------------------------
data "azurerm_client_config" "current" {}

#--------------------------------------------------------------
# Azure Key Vault
#--------------------------------------------------------------
resource "azurerm_key_vault" "main" {
  name                = var.keyvault_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  tags                = var.tags

  # Security settings
  enabled_for_disk_encryption     = false
  enabled_for_deployment          = false
  enabled_for_template_deployment = false
  enable_rbac_authorization       = true
  purge_protection_enabled        = var.enable_purge_protection
  soft_delete_retention_days      = var.soft_delete_retention_days

  # Network rules
  network_acls {
    default_action             = var.enable_private_endpoint ? "Deny" : "Allow"
    bypass                     = "AzureServices"
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }
}

#--------------------------------------------------------------
# Private Endpoint for Key Vault
#--------------------------------------------------------------
resource "azurerm_private_endpoint" "keyvault" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "keyvault-privateserviceconnection"
    private_connection_resource_id = azurerm_key_vault.main.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "keyvault-dns-zone-group"
    private_dns_zone_ids = [var.keyvault_private_dns_zone_id]
  }
}

#--------------------------------------------------------------
# Role Assignments
#--------------------------------------------------------------

# Grant workload identity access to secrets
resource "azurerm_role_assignment" "workload_secrets_user" {
  count = var.workload_identity_principal_id != "" ? 1 : 0

  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.workload_identity_principal_id
}

# Grant current user/service principal admin access
resource "azurerm_role_assignment" "admin_secrets_officer" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

#--------------------------------------------------------------
# Secrets
#--------------------------------------------------------------

# Store GitOps PAT if provided
resource "azurerm_key_vault_secret" "gitops_pat" {
  count = var.gitops_pat != "" ? 1 : 0

  name         = "gitops-pat"
  value        = var.gitops_pat
  key_vault_id = azurerm_key_vault.main.id
  tags         = var.tags

  depends_on = [azurerm_role_assignment.admin_secrets_officer]
}
