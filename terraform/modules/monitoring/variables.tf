# Monitoring Module - Variables

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

#--------------------------------------------------------------
# Azure Monitor Workspace (Prometheus)
#--------------------------------------------------------------
variable "monitor_workspace_name" {
  description = "Name of the Azure Monitor workspace for Prometheus"
  type        = string
}

#--------------------------------------------------------------
# Azure Managed Grafana
#--------------------------------------------------------------
variable "enable_grafana" {
  description = "Enable Azure Managed Grafana deployment"
  type        = bool
  default     = true
}

variable "deploy_dashboards" {
  description = "Deploy Grafana dashboards via API"
  type        = bool
  default     = true
}

variable "grafana_name" {
  description = "Name of the Azure Managed Grafana instance"
  type        = string
}

variable "grafana_admin_object_ids" {
  description = "List of Azure AD object IDs to grant Grafana Admin role"
  type        = list(string)
  default     = []
}

#--------------------------------------------------------------
# Prometheus Alerts
#--------------------------------------------------------------
variable "enable_prometheus_alerts" {
  description = "Enable Prometheus alerting rules"
  type        = bool
  default     = false
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster for Prometheus rules"
  type        = string
  default     = ""
}

variable "alert_action_group_id" {
  description = "ID of the Action Group for alert notifications"
  type        = string
  default     = null
}
