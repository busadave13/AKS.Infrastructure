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

variable "node_resource_group" {
  description = "Name of the resource group for AKS node pool resources (VMs, disks, NICs). If not specified, Azure will auto-generate a name in the format MC_<resource-group>_<cluster-name>_<location>"
  type        = string
  default     = null
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

variable "system_subnet_id" {
  description = "ID of the subnet for system node pool"
  type        = string
}

variable "workload_subnet_id" {
  description = "ID of the subnet for workload node pool"
  type        = string
}

variable "admin_group_object_ids" {
  description = "List of Azure AD group object IDs for cluster admin access"
  type        = list(string)
  default     = []
}

variable "admin_user_object_ids" {
  description = "List of Azure AD user object IDs for cluster admin access (Azure Kubernetes Service RBAC Cluster Admin role)"
  type        = list(string)
  default     = []
}

variable "egress_public_ip_id" {
  description = "ID of the public IP for load balancer egress"
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
  description = "Availability zones for system node pool. Empty list disables zones (required for single-node clusters)."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "system_node_max_pods" {
  description = "Maximum number of pods per node in the system node pool"
  type        = number
  default     = 30
}

#--------------------------------------------------------------
# Workload Node Pool
#--------------------------------------------------------------
variable "enable_workload_node_pool" {
  description = "Enable separate workload node pool. Set to false for single-node clusters where workloads run on system nodes."
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
