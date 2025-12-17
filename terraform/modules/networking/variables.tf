# Networking Module - Variables

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

variable "vnet_name" {
  description = "Name of the virtual network"
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
}

variable "aks_subnet_name" {
  description = "Name of the AKS nodes subnet"
  type        = string
}

variable "aks_subnet_prefix" {
  description = "CIDR prefix for the AKS nodes subnet"
  type        = string
}

variable "pe_subnet_name" {
  description = "Name of the private endpoints subnet"
  type        = string
}

variable "pe_subnet_prefix" {
  description = "CIDR prefix for the private endpoints subnet"
  type        = string
}

variable "nsg_name" {
  description = "Name of the network security group"
  type        = string
}
