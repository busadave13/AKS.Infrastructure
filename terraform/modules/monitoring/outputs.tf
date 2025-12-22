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
