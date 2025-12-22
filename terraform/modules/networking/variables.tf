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

#--------------------------------------------------------------
# System Subnet
#--------------------------------------------------------------
variable "system_subnet_prefix" {
  description = "CIDR prefix for the system node pool subnet"
  type        = string
}

variable "system_nsg_name" {
  description = "Name of the NSG for the system subnet"
  type        = string
}

#--------------------------------------------------------------
# Workload Subnet
#--------------------------------------------------------------
variable "workload_subnet_prefix" {
  description = "CIDR prefix for the workload node pool subnet"
  type        = string
}

variable "workload_nsg_name" {
  description = "Name of the NSG for the workload subnet"
  type        = string
}

#--------------------------------------------------------------
# Private Subnet
#--------------------------------------------------------------
variable "private_subnet_prefix" {
  description = "CIDR prefix for the private endpoints subnet"
  type        = string
}

variable "private_nsg_name" {
  description = "Name of the NSG for the private subnet"
  type        = string
}

#--------------------------------------------------------------
# Public IP for Egress
#--------------------------------------------------------------
variable "egress_public_ip_name" {
  description = "Name of the public IP for load balancer egress"
  type        = string
}
