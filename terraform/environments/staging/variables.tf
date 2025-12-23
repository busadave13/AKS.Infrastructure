# Staging Environment - Variables

#--------------------------------------------------------------
# General
#--------------------------------------------------------------
variable "identifier" {
  description = "Project or workload identifier used in resource naming"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.identifier))
    error_message = "Identifier must contain only lowercase letters and numbers."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

#--------------------------------------------------------------
# Networking
#--------------------------------------------------------------
variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "system_subnet_prefix" {
  description = "CIDR prefix for the system node pool subnet"
  type        = string
}

variable "workload_subnet_prefix" {
  description = "CIDR prefix for the workload node pool subnet"
  type        = string
}

variable "private_subnet_prefix" {
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

variable "aks_admin_user_object_ids" {
  description = "List of Azure AD user object IDs for AKS admin access (Azure Kubernetes Service RBAC Cluster Admin role)"
  type        = list(string)
  default     = []
}

# System Node Pool
variable "system_node_count" {
  description = "Number of nodes in the system node pool"
  type        = number
  default     = 2
}

variable "system_node_vm_size" {
  description = "VM size for system node pool"
  type        = string
  default     = "Standard_B2ms"
}

variable "system_node_zones" {
  description = "Availability zones for system node pool. Empty list disables zones."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "system_node_max_pods" {
  description = "Maximum number of pods per node in the system node pool"
  type        = number
  default     = 30
}

# Workload Node Pool
variable "enable_workload_node_pool" {
  description = "Enable separate workload node pool"
  type        = bool
  default     = true
}

variable "workload_node_count" {
  description = "Number of nodes in the workload node pool"
  type        = number
  default     = 2
}

variable "workload_node_vm_size" {
  description = "VM size for workload node pool"
  type        = string
  default     = "Standard_B2ms"
}

variable "workload_node_zones" {
  description = "Availability zones for workload node pool. Empty list disables zones."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "workload_node_spot" {
  description = "Whether to use spot instances for workload node pool"
  type        = bool
  default     = true
}

variable "workload_node_max_pods" {
  description = "Maximum number of pods per node in the workload node pool"
  type        = number
  default     = 30
}

#--------------------------------------------------------------
# ACR
#--------------------------------------------------------------
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

variable "public_repo" {
  description = "Whether the GitOps repository is public (no authentication required)"
  type        = bool
  default     = false
}

variable "git_https_user" {
  description = "HTTPS username for Git authentication (not required for public repos)"
  type        = string
  default     = "git"
}

variable "gitops_pat" {
  description = "Personal Access Token for Git authentication (not required for public repos)"
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
