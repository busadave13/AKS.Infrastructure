# Networking Module
# Creates VNet, subnets, NSGs, and private DNS zones

#--------------------------------------------------------------
# Resource Group
#--------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

#--------------------------------------------------------------
# Virtual Network
#--------------------------------------------------------------
resource "azurerm_virtual_network" "main" {
  name                = var.vnet_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.vnet_address_space
  tags                = var.tags
}

#--------------------------------------------------------------
# Subnets
#--------------------------------------------------------------

# Cluster Subnet (unified subnet for all AKS node pools)
resource "azurerm_subnet" "cluster" {
  name                 = "cluster-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.cluster_subnet_prefix]

  # Required for Azure CNI Overlay
  service_endpoints = [
    "Microsoft.ContainerRegistry",
    "Microsoft.KeyVault",
    "Microsoft.Storage"
  ]
}

# Private Endpoints Subnet
resource "azurerm_subnet" "private" {
  name                 = "private-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.private_subnet_prefix]

  # Disable network policies for private endpoints
  private_endpoint_network_policies = "Disabled"
}

#--------------------------------------------------------------
# Network Security Groups
#--------------------------------------------------------------

# Cluster Subnet NSG (unified NSG for all AKS node pools)
# NSG rules use destination_address_prefix = "*" because Azure Load Balancer
# performs DNAT before packets reach the NSG, so the destination IP is the
# public IP, not the subnet CIDR.
resource "azurerm_network_security_group" "cluster" {
  name                = var.cluster_nsg_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  # Allow HTTPS inbound from Internet (for Istio Gateway)
  # destination_address_prefix must be "*" because Azure LB DNAT'd traffic
  # arrives with public IP as destination, not subnet CIDR
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Allow HTTP inbound from Internet (for Istio Gateway)
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Allow Istio health probe port from Internet
  security_rule {
    name                       = "AllowIstioHealthProbe"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "15021"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Allow Kubernetes NodePort range from Internet (for LoadBalancer services)
  security_rule {
    name                       = "AllowNodePorts"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "30000-32767"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  # Allow all intra-VNet traffic (required for AKS cross-node communication)
  security_rule {
    name                       = "AllowVNetInbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  # Allow Azure Load Balancer health probes
  security_rule {
    name                       = "AllowAzureLoadBalancer"
    priority                   = 210
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  # Deny all other inbound traffic
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Private Subnet NSG
resource "azurerm_network_security_group" "private" {
  name                = var.private_nsg_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags

  # Allow HTTPS inbound from VNet only (private endpoints)
  security_rule {
    name                       = "AllowHTTPSFromVNet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = var.private_subnet_prefix
  }

  # Deny all other inbound traffic
  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

#--------------------------------------------------------------
# NSG Subnet Associations
#--------------------------------------------------------------

# Associate NSG with Cluster subnet
resource "azurerm_subnet_network_security_group_association" "cluster" {
  subnet_id                 = azurerm_subnet.cluster.id
  network_security_group_id = azurerm_network_security_group.cluster.id
}

# Associate NSG with Private subnet
resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.private.id
}

#--------------------------------------------------------------
# Public IP for Load Balancer Egress
#--------------------------------------------------------------
resource "azurerm_public_ip" "egress" {
  name                = var.egress_public_ip_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = length(var.zones) > 0 ? var.zones : null
  tags                = var.tags
}

#--------------------------------------------------------------
# Public IP for Ingress (with DNS label)
#--------------------------------------------------------------
resource "azurerm_public_ip" "ingress" {
  name                = var.ingress_public_ip_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.ingress_dns_label
  zones               = length(var.zones) > 0 ? var.zones : null
  tags                = var.tags
}

#--------------------------------------------------------------
# Private DNS Zones
#--------------------------------------------------------------

# Private DNS Zone for Azure Container Registry
resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

# Link ACR DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "acr" {
  name                  = "acr-dns-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.acr.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false
  tags                  = var.tags
}

# Private DNS Zone for Key Vault
resource "azurerm_private_dns_zone" "keyvault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}

# Link Key Vault DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  name                  = "keyvault-dns-link"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault.name
  virtual_network_id    = azurerm_virtual_network.main.id
  registration_enabled  = false
  tags                  = var.tags
}
