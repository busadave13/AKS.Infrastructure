# Grafana Dashboard Resources
# Deploys dashboards to Azure Managed Grafana using azapi

#--------------------------------------------------------------
# Locals for Dashboard Configuration
#--------------------------------------------------------------

locals {
  dashboard_files = var.enable_grafana && var.deploy_dashboards ? fileset("${path.module}/dashboards", "*.json") : []

  # Map of dashboard filename to content
  dashboards = {
    for file in local.dashboard_files :
    trimsuffix(file, ".json") => jsondecode(file("${path.module}/dashboards/${file}"))
  }
}

#--------------------------------------------------------------
# Dashboard Deployment via Azure API
# Uses azapi_resource_action to call Grafana REST API through Azure
#--------------------------------------------------------------

resource "azapi_resource_action" "grafana_dashboard" {
  for_each = var.enable_grafana && var.deploy_dashboards ? local.dashboards : {}

  type        = "Microsoft.Dashboard/grafana@2023-09-01"
  resource_id = "${azurerm_dashboard_grafana.main[0].id}/dashboards/${each.value.uid}"
  method      = "PUT"

  body = {
    properties = {
      definition = jsonencode({
        dashboard = each.value
        overwrite = true
        message   = "Deployed via Terraform"
      })
    }
  }

  response_export_values = ["*"]

  depends_on = [
    azurerm_dashboard_grafana.main,
    azurerm_role_assignment.grafana_monitoring_reader
  ]
}

#--------------------------------------------------------------
# Output dashboard deployment info
#--------------------------------------------------------------
output "grafana_dashboard_count" {
  description = "Number of dashboards deployed"
  value       = var.enable_grafana && var.deploy_dashboards ? length(local.dashboard_files) : 0
}

output "grafana_dashboard_names" {
  description = "Names of deployed dashboards"
  value       = var.enable_grafana && var.deploy_dashboards ? keys(local.dashboards) : []
}
