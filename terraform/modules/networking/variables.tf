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
# Cluster Subnet (unified subnet for all AKS node pools)
#--------------------------------------------------------------
variable "cluster_subnet_prefix" {
  description = "CIDR prefix for the unified AKS cluster subnet (system and workload node pools)"
  type        = string
}

variable "cluster_nsg_name" {
  description = "Name of the NSG for the cluster subnet"
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

#--------------------------------------------------------------
# Public IP for Ingress
#--------------------------------------------------------------
variable "ingress_public_ip_name" {
  description = "Name of the public IP for ingress traffic"
  type        = string
}

variable "ingress_dns_label" {
  description = "DNS label for the ingress public IP (creates <label>.<region>.cloudapp.azure.com)"
  type        = string
}

#--------------------------------------------------------------
# Availability Zones
#--------------------------------------------------------------
variable "zones" {
  description = "Availability zones for zone-redundant resources. Empty list disables zones."
  type        = list(string)
  default     = []
}
