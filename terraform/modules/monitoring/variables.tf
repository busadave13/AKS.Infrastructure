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
# Log Analytics
#--------------------------------------------------------------
variable "log_analytics_name" {
  description = "Name of the Log Analytics workspace"
  type        = string
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = 30
}

variable "daily_quota_gb" {
  description = "Daily ingestion quota in GB (-1 for no limit)"
  type        = number
  default     = -1
}

#--------------------------------------------------------------
# Azure Monitor Workspace (Prometheus)
#--------------------------------------------------------------
variable "monitor_workspace_name" {
  description = "Name of the Azure Monitor workspace"
  type        = string
}

#--------------------------------------------------------------
# Azure Managed Grafana
#--------------------------------------------------------------
variable "enable_grafana" {
  description = "Enable Azure Managed Grafana"
  type        = bool
  default     = true
}

variable "grafana_name" {
  description = "Name of the Azure Managed Grafana instance"
  type        = string
  default     = ""
}

variable "grafana_admin_object_ids" {
  description = "List of Azure AD object IDs to grant Grafana Admin role"
  type        = list(string)
  default     = []
}

#--------------------------------------------------------------
# Prometheus Alerting
#--------------------------------------------------------------
variable "enable_prometheus_alerts" {
  description = "Enable Prometheus alerting rules"
  type        = bool
  default     = false
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster (for alert rule group)"
  type        = string
  default     = ""
}

variable "alert_action_group_id" {
  description = "ID of the action group for alert notifications"
  type        = string
  default     = ""
}
