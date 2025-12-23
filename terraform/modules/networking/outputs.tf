# Networking Module - Outputs

#--------------------------------------------------------------
# Resource Group
#--------------------------------------------------------------
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

#--------------------------------------------------------------
# Virtual Network
#--------------------------------------------------------------
output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

#--------------------------------------------------------------
# Cluster Subnet (unified subnet for all AKS node pools)
#--------------------------------------------------------------
output "cluster_subnet_id" {
  description = "ID of the unified AKS cluster subnet"
  value       = azurerm_subnet.cluster.id
}

output "cluster_subnet_name" {
  description = "Name of the unified AKS cluster subnet"
  value       = azurerm_subnet.cluster.name
}

output "cluster_nsg_id" {
  description = "ID of the cluster subnet NSG"
  value       = azurerm_network_security_group.cluster.id
}

#--------------------------------------------------------------
# Private Subnet
#--------------------------------------------------------------
output "private_subnet_id" {
  description = "ID of the private endpoints subnet"
  value       = azurerm_subnet.private.id
}

output "private_subnet_name" {
  description = "Name of the private endpoints subnet"
  value       = azurerm_subnet.private.name
}

output "private_nsg_id" {
  description = "ID of the private subnet NSG"
  value       = azurerm_network_security_group.private.id
}

#--------------------------------------------------------------
# Private DNS Zones
#--------------------------------------------------------------
output "acr_private_dns_zone_id" {
  description = "ID of the ACR private DNS zone"
  value       = azurerm_private_dns_zone.acr.id
}

output "keyvault_private_dns_zone_id" {
  description = "ID of the Key Vault private DNS zone"
  value       = azurerm_private_dns_zone.keyvault.id
}

#--------------------------------------------------------------
# Egress Public IP
#--------------------------------------------------------------
output "egress_public_ip_id" {
  description = "ID of the public IP for load balancer egress"
  value       = azurerm_public_ip.egress.id
}

output "egress_public_ip_address" {
  description = "IP address of the public IP for load balancer egress"
  value       = azurerm_public_ip.egress.ip_address
}

#--------------------------------------------------------------
# Ingress Public IP
#--------------------------------------------------------------
output "ingress_public_ip_id" {
  description = "ID of the public IP for ingress traffic"
  value       = azurerm_public_ip.ingress.id
}

output "ingress_public_ip_address" {
  description = "IP address of the public IP for ingress traffic"
  value       = azurerm_public_ip.ingress.ip_address
}

output "ingress_public_ip_fqdn" {
  description = "FQDN of the public IP for ingress traffic"
  value       = azurerm_public_ip.ingress.fqdn
}
