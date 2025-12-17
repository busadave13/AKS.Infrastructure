# Monitoring Module
# Creates Log Analytics, Azure Monitor Workspace, and Managed Grafana

#--------------------------------------------------------------
# Log Analytics Workspace
#--------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "main" {
  name                = var.log_analytics_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.log_retention_days
  tags                = var.tags

  # Daily cap (optional, for cost control)
  daily_quota_gb = var.daily_quota_gb
}

#--------------------------------------------------------------
# Log Analytics Solutions (Container Insights)
#--------------------------------------------------------------
resource "azurerm_log_analytics_solution" "container_insights" {
  solution_name         = "ContainerInsights"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.main.id
  workspace_name        = azurerm_log_analytics_workspace.main.name
  tags                  = var.tags

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}

#--------------------------------------------------------------
# Azure Monitor Workspace (for Managed Prometheus)
#--------------------------------------------------------------
resource "azurerm_monitor_workspace" "main" {
  name                = var.monitor_workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

#--------------------------------------------------------------
# Azure Managed Grafana
#--------------------------------------------------------------
resource "azurerm_dashboard_grafana" "main" {
  count = var.enable_grafana ? 1 : 0

  name                              = var.grafana_name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  grafana_major_version             = 10
  sku                               = "Standard"
  zone_redundancy_enabled           = false
  api_key_enabled                   = true
  deterministic_outbound_ip_enabled = false
  public_network_access_enabled     = true
  tags                              = var.tags

  identity {
    type = "SystemAssigned"
  }

  azure_monitor_workspace_integrations {
    resource_id = azurerm_monitor_workspace.main.id
  }
}

#--------------------------------------------------------------
# Role Assignments for Grafana
#--------------------------------------------------------------

# Grant Grafana access to Azure Monitor Workspace
resource "azurerm_role_assignment" "grafana_monitoring_reader" {
  count = var.enable_grafana ? 1 : 0

  scope                = azurerm_monitor_workspace.main.id
  role_definition_name = "Monitoring Reader"
  principal_id         = azurerm_dashboard_grafana.main[0].identity[0].principal_id
}

# Grant Grafana access to Log Analytics Workspace
resource "azurerm_role_assignment" "grafana_log_analytics_reader" {
  count = var.enable_grafana ? 1 : 0

  scope                = azurerm_log_analytics_workspace.main.id
  role_definition_name = "Log Analytics Reader"
  principal_id         = azurerm_dashboard_grafana.main[0].identity[0].principal_id
}

# Grant admin users access to Grafana
resource "azurerm_role_assignment" "grafana_admin" {
  for_each = var.enable_grafana ? toset(var.grafana_admin_object_ids) : []

  scope                = azurerm_dashboard_grafana.main[0].id
  role_definition_name = "Grafana Admin"
  principal_id         = each.value
}

#--------------------------------------------------------------
# Prometheus Rule Groups (Alerting Rules)
#--------------------------------------------------------------
resource "azurerm_monitor_alert_prometheus_rule_group" "kubernetes" {
  count = var.enable_prometheus_alerts ? 1 : 0

  name                = "kubernetes-alerts-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  cluster_name        = var.aks_cluster_name
  rule_group_enabled  = true
  interval            = "PT1M"
  scopes              = [azurerm_monitor_workspace.main.id]
  tags                = var.tags

  # High Pod CPU Usage Alert
  rule {
    alert      = "HighPodCPUUsage"
    enabled    = true
    expression = "sum(rate(container_cpu_usage_seconds_total{container!=\"\"}[5m])) by (pod, namespace) > 0.8"
    for        = "PT5M"
    severity   = 3

    labels = {
      severity = "warning"
    }

    annotations = {
      summary     = "High CPU usage detected for pod {{ $labels.pod }}"
      description = "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} has high CPU usage"
    }

    action {
      action_group_id = var.alert_action_group_id
    }
  }

  # High Pod Memory Usage Alert
  rule {
    alert      = "HighPodMemoryUsage"
    enabled    = true
    expression = "sum(container_memory_working_set_bytes{container!=\"\"}) by (pod, namespace) / sum(container_spec_memory_limit_bytes{container!=\"\"}) by (pod, namespace) > 0.8"
    for        = "PT5M"
    severity   = 3

    labels = {
      severity = "warning"
    }

    annotations = {
      summary     = "High memory usage detected for pod {{ $labels.pod }}"
      description = "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} has high memory usage"
    }

    action {
      action_group_id = var.alert_action_group_id
    }
  }

  # Pod Restart Alert
  rule {
    alert      = "PodRestartingTooOften"
    enabled    = true
    expression = "rate(kube_pod_container_status_restarts_total[15m]) * 60 * 15 > 3"
    for        = "PT5M"
    severity   = 2

    labels = {
      severity = "critical"
    }

    annotations = {
      summary     = "Pod {{ $labels.pod }} is restarting frequently"
      description = "Pod {{ $labels.pod }} in namespace {{ $labels.namespace }} has restarted more than 3 times in 15 minutes"
    }

    action {
      action_group_id = var.alert_action_group_id
    }
  }
}
