# Monitoring Module

This module creates Azure monitoring infrastructure including:

- Log Analytics Workspace with Container Insights
- Azure Monitor Workspace (Managed Prometheus)
- Azure Managed Grafana (optional)
- Prometheus alerting rules (optional)

## Usage

```hcl
module "monitoring" {
  source = "../../modules/monitoring"

  resource_group_name = module.networking.resource_group_name
  location            = module.networking.resource_group_location
  environment         = "dev"
  
  # Log Analytics
  log_analytics_name = "log-platform-dev-wus3"
  log_retention_days = 30
  
  # Azure Monitor (Prometheus)
  monitor_workspace_name = "amw-platform-dev-wus3"
  
  # Grafana
  enable_grafana           = true
  grafana_name             = "grafana-platform-dev-wus3"
  grafana_admin_object_ids = ["<user-or-group-object-id>"]
  
  # Alerting (optional)
  enable_prometheus_alerts = false
  aks_cluster_name         = module.aks.cluster_name
  alert_action_group_id    = ""
  
  tags = {
    Environment = "dev"
    Owner       = "platform-team"
    ManagedBy   = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| resource_group_name | Name of the resource group | string | - | yes |
| location | Azure region | string | - | yes |
| environment | Environment name | string | - | yes |
| log_analytics_name | Log Analytics workspace name | string | - | yes |
| log_retention_days | Log retention in days | number | 30 | no |
| daily_quota_gb | Daily ingestion quota (-1 for unlimited) | number | -1 | no |
| monitor_workspace_name | Azure Monitor workspace name | string | - | yes |
| enable_grafana | Enable Managed Grafana | bool | true | no |
| grafana_name | Grafana instance name | string | "" | no |
| grafana_admin_object_ids | Azure AD object IDs for admin access | list(string) | [] | no |
| enable_prometheus_alerts | Enable Prometheus alerts | bool | false | no |
| aks_cluster_name | AKS cluster name for alerts | string | "" | no |
| alert_action_group_id | Action group for notifications | string | "" | no |
| tags | Resource tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| log_analytics_workspace_id | ID of Log Analytics workspace |
| log_analytics_workspace_name | Name of Log Analytics workspace |
| monitor_workspace_id | ID of Azure Monitor workspace |
| monitor_workspace_name | Name of Azure Monitor workspace |
| monitor_workspace_query_endpoint | Prometheus query endpoint |
| grafana_id | ID of Grafana instance |
| grafana_name | Name of Grafana instance |
| grafana_endpoint | Grafana dashboard URL |
| grafana_identity_principal_id | Grafana managed identity |

## Components

### Log Analytics Workspace
- Container Insights solution enabled
- Configurable retention and quotas
- Integrated with AKS for log collection

### Azure Monitor Workspace
- Stores Prometheus metrics from AKS
- Query endpoint for PromQL queries
- Integration with Grafana

### Azure Managed Grafana
- Version 10 with Standard SKU
- System-assigned managed identity
- Auto-integrated with Azure Monitor
- Role assignments for admin access

### Prometheus Alerts (Optional)
Pre-configured alert rules:
- High Pod CPU Usage (>80% for 5 min)
- High Pod Memory Usage (>80% for 5 min)
- Pod Restarting Too Often (>3 restarts in 15 min)

## AKS Integration

Configure AKS to send metrics to this monitoring stack:

```hcl
module "aks" {
  # ... other config ...
  
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  monitor_workspace_id       = module.monitoring.monitor_workspace_id
}
