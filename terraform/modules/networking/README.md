# Networking Module

This module creates the networking infrastructure for the AKS platform including:

- Resource Group
- Virtual Network
- Subnets (AKS nodes, Private Endpoints)
- Network Security Group
- Private DNS Zones (ACR, Key Vault)

## Usage

```hcl
module "networking" {
  source = "../../modules/networking"

  resource_group_name = "rg-aks-platform-dev-wus3"
  location            = "westus3"
  
  vnet_name          = "vnet-platform-dev-wus3"
  vnet_address_space = ["10.0.0.0/16"]
  
  aks_subnet_name   = "snet-aks-nodes-dev-wus3"
  aks_subnet_prefix = "10.0.0.0/22"
  
  pe_subnet_name   = "snet-privateendpoints-dev-wus3"
  pe_subnet_prefix = "10.0.4.0/24"
  
  nsg_name = "nsg-aks-dev-wus3"
  
  tags = {
    Environment = "dev"
    Owner       = "platform-team"
    ManagedBy   = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Required |
|------|-------------|------|----------|
| resource_group_name | Name of the resource group | string | yes |
| location | Azure region for resources | string | yes |
| vnet_name | Name of the virtual network | string | yes |
| vnet_address_space | Address space for the VNet | list(string) | yes |
| aks_subnet_name | Name of the AKS nodes subnet | string | yes |
| aks_subnet_prefix | CIDR prefix for AKS nodes subnet | string | yes |
| pe_subnet_name | Name of the private endpoints subnet | string | yes |
| pe_subnet_prefix | CIDR prefix for private endpoints subnet | string | yes |
| nsg_name | Name of the network security group | string | yes |
| tags | Tags to apply to all resources | map(string) | no |

## Outputs

| Name | Description |
|------|-------------|
| resource_group_name | Name of the resource group |
| resource_group_id | ID of the resource group |
| resource_group_location | Location of the resource group |
| vnet_id | ID of the virtual network |
| vnet_name | Name of the virtual network |
| aks_subnet_id | ID of the AKS nodes subnet |
| aks_subnet_name | Name of the AKS nodes subnet |
| pe_subnet_id | ID of the private endpoints subnet |
| pe_subnet_name | Name of the private endpoints subnet |
| nsg_id | ID of the network security group |
| acr_private_dns_zone_id | ID of the ACR private DNS zone |
| keyvault_private_dns_zone_id | ID of the Key Vault private DNS zone |

## Network Architecture

```
VNet: 10.0.0.0/16
├── snet-aks-nodes: 10.0.0.0/22 (1,019 IPs)
│   ├── AKS node pool nodes
│   └── Pod network uses Overlay (10.244.0.0/16)
└── snet-privateendpoints: 10.0.4.0/24 (251 IPs)
    ├── ACR private endpoint
    └── Key Vault private endpoint
```

## Security Rules

| Rule | Direction | Priority | Source | Destination | Port | Action |
|------|-----------|----------|--------|-------------|------|--------|
| AllowHTTPS | Inbound | 100 | Internet | AKS Subnet | 443 | Allow |
| AllowHTTP | Inbound | 110 | Internet | AKS Subnet | 80 | Allow |
| DenyAllInbound | Inbound | 4096 | Any | Any | Any | Deny |
