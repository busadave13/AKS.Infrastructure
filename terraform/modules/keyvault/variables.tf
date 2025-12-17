# Key Vault Module - Variables

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

variable "keyvault_name" {
  description = "Name of the Azure Key Vault (must be globally unique, 3-24 chars)"
  type        = string
}

variable "enable_purge_protection" {
  description = "Enable purge protection (cannot be disabled once enabled)"
  type        = bool
  default     = false
}

variable "soft_delete_retention_days" {
  description = "Number of days to retain soft-deleted secrets"
  type        = number
  default     = 7
}

variable "allowed_ip_ranges" {
  description = "List of allowed IP ranges for network access"
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "List of allowed subnet IDs for network access"
  type        = list(string)
  default     = []
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint for Key Vault"
  type        = bool
  default     = false
}

variable "private_endpoint_name" {
  description = "Name of the private endpoint for Key Vault"
  type        = string
  default     = ""
}

variable "private_endpoint_subnet_id" {
  description = "ID of the subnet for the private endpoint"
  type        = string
  default     = ""
}

variable "keyvault_private_dns_zone_id" {
  description = "ID of the private DNS zone for Key Vault"
  type        = string
  default     = ""
}

variable "workload_identity_principal_id" {
  description = "Principal ID of the workload identity for secret access"
  type        = string
  default     = ""
}

variable "gitops_pat" {
  description = "Personal Access Token for GitOps repository access (stored as secret)"
  type        = string
  default     = ""
  sensitive   = true
}
