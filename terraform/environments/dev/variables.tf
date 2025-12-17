# Development Environment - Variables

#--------------------------------------------------------------
# General
#--------------------------------------------------------------
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "location_short" {
  description = "Short name for Azure region (e.g., eastus2)"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

#--------------------------------------------------------------
# Networking
#--------------------------------------------------------------
variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "aks_subnet_prefix" {
  description = "CIDR prefix for the AKS nodes subnet"
  type        = string
}

variable "pe_subnet_prefix" {
  description = "CIDR prefix for the private endpoints subnet"
  type        = string
}

variable "enable_private_endpoints" {
  description = "Enable private endpoints for PaaS services"
  type        = bool
  default     = false
}

#--------------------------------------------------------------
# Monitoring
#--------------------------------------------------------------
variable "log_retention_days" {
  description = "Number of days to retain logs in Log Analytics"
  type        = number
  default     = 30
}

variable "enable_grafana" {
  description = "Enable Azure Managed Grafana"
  type        = bool
  default     = true
}

variable "grafana_admin_object_ids" {
  description = "List of Azure AD object IDs for Grafana admin access"
  type        = list(string)
  default     = []
}

#--------------------------------------------------------------
# AKS
#--------------------------------------------------------------
variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
  default     = "1.30"
}

variable "aks_admin_group_object_ids" {
  description = "List of Azure AD group object IDs for AKS admin access"
  type        = list(string)
  default     = []
}

# System Node Pool
variable "system_node_count" {
  description = "Initial number of nodes in the system node pool"
  type        = number
  default     = 2
}

variable "system_node_min_count" {
  description = "Minimum number of nodes in the system node pool"
  type        = number
  default     = 2
}

variable "system_node_max_count" {
  description = "Maximum number of nodes in the system node pool"
  type        = number
  default     = 3
}

variable "system_node_vm_size" {
  description = "VM size for system node pool"
  type        = string
  default     = "Standard_B2ms"
}

# Workload Node Pool
variable "workload_node_count" {
  description = "Initial number of nodes in the workload node pool"
  type        = number
  default     = 2
}

variable "workload_node_min_count" {
  description = "Minimum number of nodes in the workload node pool"
  type        = number
  default     = 1
}

variable "workload_node_max_count" {
  description = "Maximum number of nodes in the workload node pool"
  type        = number
  default     = 4
}

variable "workload_node_vm_size" {
  description = "VM size for workload node pool"
  type        = string
  default     = "Standard_B2ms"
}

variable "workload_node_spot" {
  description = "Whether to use spot instances for workload node pool"
  type        = bool
  default     = true
}

#--------------------------------------------------------------
# ACR
#--------------------------------------------------------------
variable "acr_name" {
  description = "Name of the Azure Container Registry (must be globally unique)"
  type        = string
}

variable "acr_sku" {
  description = "SKU of the Azure Container Registry"
  type        = string
  default     = "Basic"
}

#--------------------------------------------------------------
# GitOps
#--------------------------------------------------------------
variable "enable_gitops" {
  description = "Enable GitOps with Flux v2"
  type        = bool
  default     = false
}

variable "gitops_repo_url" {
  description = "URL of the GitOps repository"
  type        = string
  default     = ""
}

variable "gitops_branch" {
  description = "Branch to sync from in GitOps repository"
  type        = string
  default     = "main"
}

variable "git_https_user" {
  description = "HTTPS username for Git authentication"
  type        = string
  default     = "git"
}

variable "gitops_pat" {
  description = "Personal Access Token for Git authentication"
  type        = string
  sensitive   = true
  default     = ""
}

variable "sync_interval_seconds" {
  description = "Interval in seconds for syncing with Git repository"
  type        = number
  default     = 60
}

variable "retry_interval_seconds" {
  description = "Interval in seconds for retrying failed syncs"
  type        = number
  default     = 60
}
