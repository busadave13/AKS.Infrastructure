# Grafana Dashboard Resources
# Deploys dashboards to Azure Managed Grafana

#--------------------------------------------------------------
# Grafana Folders for Dashboard Organization
#--------------------------------------------------------------

#--------------------------------------------------------------
# Dashboard Deployment via API (using local-exec)
# Note: Dashboards are deployed via Grafana HTTP API
#--------------------------------------------------------------

locals {
  dashboard_files = var.enable_grafana ? fileset("${path.module}/dashboards", "*.json") : []

  # Azure Managed Prometheus datasource configuration
  # Grafana auto-creates a datasource named "Azure Monitor" for integrated workspaces
  prometheus_datasource_name = "Azure Monitor"
}

# Deploy each dashboard JSON file
resource "null_resource" "grafana_dashboards" {
  for_each = var.enable_grafana && var.deploy_dashboards ? toset(local.dashboard_files) : []

  triggers = {
    dashboard_hash = filesha256("${path.module}/dashboards/${each.value}")
    grafana_id     = var.enable_grafana ? azurerm_dashboard_grafana.main[0].id : ""
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<-EOT
      # Get Grafana endpoint
      GRAFANA_ENDPOINT="${azurerm_dashboard_grafana.main[0].endpoint}"
      
      # Get access token using Azure CLI
      ACCESS_TOKEN=$(az grafana api-key create \
        --name ${azurerm_dashboard_grafana.main[0].name} \
        --resource-group ${var.resource_group_name} \
        --key dashboard-deploy-$(date +%s) \
        --role Admin \
        --time-to-live 1h \
        --query key -o tsv 2>/dev/null || \
        az account get-access-token --resource https://grafana.azure.com --query accessToken -o tsv)
      
      # Read dashboard JSON and update datasource references
      DASHBOARD_JSON=$(cat "${path.module}/dashboards/${each.value}" | \
        sed 's/"datasource": "Prometheus"/"datasource": {"type": "prometheus", "uid": "azure-monitor-obo"}/g' | \
        sed 's/"datasource": "-- Grafana --"/"datasource": {"type": "grafana", "uid": "-- Grafana --"}/g')
      
      # Create the API payload
      PAYLOAD=$(jq -n --argjson dashboard "$DASHBOARD_JSON" '{
        "dashboard": $dashboard,
        "overwrite": true,
        "message": "Deployed via Terraform"
      }')
      
      # Deploy dashboard
      curl -s -X POST "$GRAFANA_ENDPOINT/api/dashboards/db" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -H "Content-Type: application/json" \
        -d "$PAYLOAD"
    EOT
  }

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
