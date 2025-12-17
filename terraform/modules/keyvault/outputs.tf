# Key Vault Module - Outputs

output "keyvault_id" {
  description = "ID of the Azure Key Vault"
  value       = azurerm_key_vault.main.id
}

output "keyvault_name" {
  description = "Name of the Azure Key Vault"
  value       = azurerm_key_vault.main.name
}

output "keyvault_uri" {
  description = "URI of the Azure Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "keyvault_tenant_id" {
  description = "Tenant ID of the Azure Key Vault"
  value       = azurerm_key_vault.main.tenant_id
}

output "private_endpoint_id" {
  description = "ID of the private endpoint (if enabled)"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.keyvault[0].id : null
}

output "private_endpoint_ip" {
  description = "Private IP address of the private endpoint (if enabled)"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.keyvault[0].private_service_connection[0].private_ip_address : null
}

output "gitops_pat_secret_id" {
  description = "ID of the GitOps PAT secret (if stored)"
  value       = var.gitops_pat != "" ? azurerm_key_vault_secret.gitops_pat[0].id : null
}

output "gitops_pat_secret_name" {
  description = "Name of the GitOps PAT secret"
  value       = var.gitops_pat != "" ? azurerm_key_vault_secret.gitops_pat[0].name : null
}
