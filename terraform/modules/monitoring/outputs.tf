# Monitoring Module Outputs

output "monitor_workspace_id" {
  description = "ID of the Azure Monitor workspace"
  value       = azurerm_monitor_workspace.main.id
}

output "monitor_workspace_name" {
  description = "Name of the Azure Monitor workspace"
  value       = azurerm_monitor_workspace.main.name
}

output "grafana_id" {
  description = "ID of the Azure Managed Grafana instance"
  value       = var.enable_grafana ? azurerm_dashboard_grafana.main[0].id : null
}

output "grafana_endpoint" {
  description = "Endpoint URL for Azure Managed Grafana"
  value       = var.enable_grafana ? azurerm_dashboard_grafana.main[0].endpoint : null
}

output "grafana_identity_principal_id" {
  description = "Principal ID of the Grafana managed identity"
  value       = var.enable_grafana ? azurerm_dashboard_grafana.main[0].identity[0].principal_id : null
}

#--------------------------------------------------------------
# Flagger Identity Outputs
#--------------------------------------------------------------
output "flagger_identity_id" {
  description = "ID of the Flagger managed identity"
  value       = var.enable_flagger_identity ? azurerm_user_assigned_identity.flagger[0].id : null
}

output "flagger_identity_client_id" {
  description = "Client ID of the Flagger managed identity (use in Kubernetes ServiceAccount annotation)"
  value       = var.enable_flagger_identity ? azurerm_user_assigned_identity.flagger[0].client_id : null
}

output "flagger_identity_principal_id" {
  description = "Principal ID of the Flagger managed identity"
  value       = var.enable_flagger_identity ? azurerm_user_assigned_identity.flagger[0].principal_id : null
}
