# ACR Module - Variables

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

variable "acr_name" {
  description = "Name of the Azure Container Registry (must be globally unique, alphanumeric only)"
  type        = string
}

variable "sku" {
  description = "SKU of the Azure Container Registry (Basic, Standard, Premium)"
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be one of: Basic, Standard, Premium."
  }
}

variable "georeplications" {
  description = "Geo-replication configuration (Premium SKU only)"
  type = list(object({
    location                = string
    zone_redundancy_enabled = bool
  }))
  default = []
}

variable "retention_days" {
  description = "Number of days to retain untagged manifests (Premium SKU only)"
  type        = number
  default     = 7
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint for ACR"
  type        = bool
  default     = false
}

variable "private_endpoint_name" {
  description = "Name of the private endpoint for ACR"
  type        = string
  default     = ""
}

variable "private_endpoint_subnet_id" {
  description = "ID of the subnet for the private endpoint"
  type        = string
  default     = ""
}

variable "acr_private_dns_zone_id" {
  description = "ID of the private DNS zone for ACR"
  type        = string
  default     = ""
}

variable "kubelet_identity_principal_id" {
  description = "Principal ID of the AKS kubelet identity for ACR pull access"
  type        = string
}
