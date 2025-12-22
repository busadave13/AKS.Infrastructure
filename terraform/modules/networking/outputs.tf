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
# System Subnet
#--------------------------------------------------------------
output "system_subnet_id" {
  description = "ID of the system node pool subnet"
  value       = azurerm_subnet.system.id
}

output "system_subnet_name" {
  description = "Name of the system node pool subnet"
  value       = azurerm_subnet.system.name
}

output "system_nsg_id" {
  description = "ID of the system subnet NSG"
  value       = azurerm_network_security_group.system.id
}

#--------------------------------------------------------------
# Workload Subnet
#--------------------------------------------------------------
output "workload_subnet_id" {
  description = "ID of the workload node pool subnet"
  value       = azurerm_subnet.workload.id
}

output "workload_subnet_name" {
  description = "Name of the workload node pool subnet"
  value       = azurerm_subnet.workload.name
}

output "workload_nsg_id" {
  description = "ID of the workload subnet NSG"
  value       = azurerm_network_security_group.workload.id
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
