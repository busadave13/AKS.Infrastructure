# ACR Module

This module creates an Azure Container Registry with:

- Configurable SKU (Basic, Standard, Premium)
- Optional private endpoint
- AKS kubelet identity integration (AcrPull role)
- Geo-replication support (Premium SKU)
- Image retention policies (Premium SKU)

## Usage

```hcl
module "acr" {
  source = "../../modules/acr"

  resource_group_name = module.networking.resource_group_name
  location            = module.networking.resource_group_location
  
  acr_name = "acrplatformdevwus3"
  sku      = "Basic"
  
  # AKS integration
  kubelet_identity_principal_id = module.aks.kubelet_identity_principal_id
  
  # Private endpoint (optional)
  enable_private_endpoint    = false
  private_endpoint_name      = "pep-acr-dev-wus3"
  private_endpoint_subnet_id = module.networking.pe_subnet_id
  acr_private_dns_zone_id    = module.networking.acr_private_dns_zone_id
  
  tags = {
    Environment = "dev"
    Owner       = "platform-team"
    ManagedBy   = "terraform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| resource_group_name | Name of the resource group | string | - | yes |
| location | Azure region | string | - | yes |
| acr_name | Name of the ACR (alphanumeric only) | string | - | yes |
| sku | SKU tier (Basic, Standard, Premium) | string | "Basic" | no |
| kubelet_identity_principal_id | Principal ID of AKS kubelet identity | string | - | yes |
| enable_private_endpoint | Enable private endpoint | bool | false | no |
| private_endpoint_name | Name of the private endpoint | string | "" | no |
| private_endpoint_subnet_id | Subnet ID for private endpoint | string | "" | no |
| acr_private_dns_zone_id | Private DNS zone ID for ACR | string | "" | no |
| georeplications | Geo-replication config (Premium only) | list(object) | [] | no |
| retention_days | Untagged manifest retention (Premium only) | number | 7 | no |
| tags | Resource tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| acr_id | ID of the container registry |
| acr_name | Name of the container registry |
| acr_login_server | Login server URL |
| private_endpoint_id | ID of private endpoint (if enabled) |
| private_endpoint_ip | Private IP of endpoint (if enabled) |

## SKU Comparison

| Feature | Basic | Standard | Premium |
|---------|-------|----------|---------|
| Storage | 10 GB | 100 GB | 500 GB |
| Geo-replication | ❌ | ❌ | ✅ |
| Private endpoints | ❌ | ❌ | ✅ |
| Content trust | ❌ | ❌ | ✅ |
| Retention policies | ❌ | ❌ | ✅ |

## Security

- Admin account is disabled by default
- AKS accesses ACR via managed identity (AcrPull role)
- Private endpoint support for network isolation (Premium)
