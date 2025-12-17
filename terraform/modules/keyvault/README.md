# Key Vault Module

This module creates an Azure Key Vault with:

- RBAC authorization (no access policies)
- Optional private endpoint
- Workload identity integration
- GitOps PAT secret storage

## Usage

```hcl
module "keyvault" {
  source = "../../modules/keyvault"

  resource_group_name = module.networking.resource_group_name
  location            = module.networking.resource_group_location
  
  keyvault_name = "kv-platform-dev-wus3"
  
  # Workload identity access
  workload_identity_principal_id = module.aks.workload_identity_principal_id
  
  # GitOps PAT (optional)
  gitops_pat = var.gitops_pat
  
  # Private endpoint (optional)
  enable_private_endpoint      = false
  private_endpoint_name        = "pep-kv-dev-wus3"
  private_endpoint_subnet_id   = module.networking.pe_subnet_id
  keyvault_private_dns_zone_id = module.networking.keyvault_private_dns_zone_id
  
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
| keyvault_name | Name of the Key Vault (3-24 chars) | string | - | yes |
| enable_purge_protection | Enable purge protection | bool | false | no |
| soft_delete_retention_days | Soft delete retention days | number | 7 | no |
| allowed_ip_ranges | Allowed IP ranges | list(string) | [] | no |
| allowed_subnet_ids | Allowed subnet IDs | list(string) | [] | no |
| enable_private_endpoint | Enable private endpoint | bool | false | no |
| private_endpoint_name | Private endpoint name | string | "" | no |
| private_endpoint_subnet_id | Subnet ID for private endpoint | string | "" | no |
| keyvault_private_dns_zone_id | Private DNS zone ID | string | "" | no |
| workload_identity_principal_id | Workload identity principal ID | string | "" | no |
| gitops_pat | GitOps PAT to store as secret | string | "" | no |
| tags | Resource tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| keyvault_id | ID of the Key Vault |
| keyvault_name | Name of the Key Vault |
| keyvault_uri | URI of the Key Vault |
| keyvault_tenant_id | Tenant ID of the Key Vault |
| private_endpoint_id | ID of private endpoint (if enabled) |
| private_endpoint_ip | Private IP of endpoint (if enabled) |
| gitops_pat_secret_id | ID of GitOps PAT secret (if stored) |
| gitops_pat_secret_name | Name of GitOps PAT secret |

## Security

- Uses RBAC authorization (no legacy access policies)
- Soft delete enabled by default
- Network access restricted when private endpoint is enabled
- Azure Services bypass enabled
- Workload identity gets "Key Vault Secrets User" role
- Terraform identity gets "Key Vault Secrets Officer" role

## Secrets Stored

| Secret Name | Description |
|-------------|-------------|
| gitops-pat | Personal Access Token for GitOps repository |
