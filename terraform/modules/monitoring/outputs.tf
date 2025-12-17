# Monitoring Module - Outputs

#--------------------------------------------------------------
# Log Analytics
#--------------------------------------------------------------
output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.name
}

output "log_analytics_workspace_primary_key" {
  description = "Primary shared key for the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.primary_shared_key
  sensitive   = true
}

output "log_analytics_workspace_secondary_key" {
  description = "Secondary shared key for the Log Analytics workspace"
  value       = azurerm_log_analytics_workspace.main.secondary_shared_key
  sensitive   = true
}

#--------------------------------------------------------------
# Azure Monitor Workspace
#--------------------------------------------------------------
output "monitor_workspace_id" {
  description = "ID of the Azure Monitor workspace"
  value       = azurerm_monitor_workspace.main.id
}

output "monitor_workspace_name" {
  description = "Name of the Azure Monitor workspace"
  value       = azurerm_monitor_workspace.main.name
}

output "monitor_workspace_query_endpoint" {
  description = "Query endpoint for the Azure Monitor workspace"
  value       = azurerm_monitor_workspace.main.query_endpoint
}

#--------------------------------------------------------------
# Azure Managed Grafana
#--------------------------------------------------------------
output "grafana_id" {
  description = "ID of the Azure Managed Grafana instance"
  value       = var.enable_grafana ? azurerm_dashboard_grafana.main[0].id : null
}

output "grafana_name" {
  description = "Name of the Azure Managed Grafana instance"
  value       = var.enable_grafana ? azurerm_dashboard_grafana.main[0].name : null
}

output "grafana_endpoint" {
  description = "Endpoint URL for the Azure Managed Grafana instance"
  value       = var.enable_grafana ? azurerm_dashboard_grafana.main[0].endpoint : null
}

output "grafana_identity_principal_id" {
  description = "Principal ID of the Grafana managed identity"
  value       = var.enable_grafana ? azurerm_dashboard_grafana.main[0].identity[0].principal_id : null
}
