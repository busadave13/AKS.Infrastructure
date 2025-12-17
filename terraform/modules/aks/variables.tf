# AKS Module - Variables

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

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

#--------------------------------------------------------------
# AKS Cluster
#--------------------------------------------------------------
variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for the cluster"
  type        = string
  default     = "1.30"
}

variable "aks_subnet_id" {
  description = "ID of the subnet for AKS nodes"
  type        = string
}

variable "admin_group_object_ids" {
  description = "List of Azure AD group object IDs for cluster admin access"
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace for Container Insights"
  type        = string
}

#--------------------------------------------------------------
# Identity
#--------------------------------------------------------------
variable "kubelet_identity_name" {
  description = "Name of the kubelet managed identity"
  type        = string
}

variable "workload_identity_name" {
  description = "Name of the workload managed identity"
  type        = string
}

variable "workload_identity_namespace" {
  description = "Kubernetes namespace for the workload identity service account"
  type        = string
  default     = "app-dev"
}

variable "workload_identity_service_account" {
  description = "Kubernetes service account name for workload identity"
  type        = string
  default     = "workload-identity-sa"
}

#--------------------------------------------------------------
# System Node Pool
#--------------------------------------------------------------
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

#--------------------------------------------------------------
# Workload Node Pool
#--------------------------------------------------------------
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
