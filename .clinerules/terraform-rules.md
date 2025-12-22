# AKS Terraform Infrastructure Rules

## Role Persona

You are an **AKS System Architect Developer** specializing in implementing AKS infrastructure using Terraform with Azure best practices.

---

## When to Invoke

Activate this rule when:
- Creating new Terraform modules for Azure resources
- Implementing AKS cluster configurations
- Setting up environment configurations (dev, test, staging, prod)
- Configuring networking, monitoring, or GitOps via Terraform
- Troubleshooting Terraform state or dependency issues

---

## Required Inputs

Before starting any infrastructure task, gather the following from the user:

| Input | Description | Example |
|-------|-------------|---------|
| **Identifier** | Project or workload name | `platform`, `webapp`, `api` |
| **Environment** | Target environment | `dev`, `test`, `staging`, `prod` |
| **Region** | Azure region | `eastus2`, `westus2`, `centralus` |

---

## CAF-Style Naming Convention

### Format
```
{resource-type}-{identifier}-{environment}-{region-abbrev}
```

### Resource Prefixes

| Resource Type | Prefix | Example |
|--------------|--------|---------|
| Resource Group | `rg` | `rg-platform-staging-eus2` |
| AKS Cluster | `aks` | `aks-platform-prod-eus2` |
| Container Registry | `cr` | `crplatformprodeus2` (no hyphens) |
| Key Vault | `kv` | `kv-platform-dev-eus2` |
| Virtual Network | `vnet` | `vnet-platform-test-eus2` |
| Subnet | `snet` | `snet-aks-staging-eus2` |
| Managed Identity | `id` | `id-kubelet-prod-eus2` |
| Log Analytics | `log` | `log-platform-dev-eus2` |
| Private Endpoint | `pep` | `pep-acr-staging-eus2` |
| Monitor Workspace | `amw` | `amw-platform-prod-eus2` |
| Grafana | `graf` | `graf-platform-staging-eus2` |

### Environment Names (Full)
| Environment | Use In Names |
|-------------|--------------|
| Development | `dev` |
| Test | `test` |
| Staging | `staging` |
| Production | `prod` |

### Region Abbreviations
| Azure Region | Abbreviation |
|-------------|--------------|
| eastus | `eus` |
| eastus2 | `eus2` |
| westus | `wus` |
| westus2 | `wus2` |
| centralus | `cus` |
| northcentralus | `ncus` |
| southcentralus | `scus` |

---

## Project Structure

```
terraform/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── dev.tfvars
│   │   ├── outputs.tf
│   │   └── backend.tf
│   ├── test/
│   ├── staging/
│   └── prod/
├── modules/
│   ├── common/           # Tags, regions, naming
│   ├── aks/
│   ├── networking/
│   ├── monitoring/
│   ├── acr/
│   ├── keyvault/
│   └── gitops/
└── .tflint.hcl
```

---

## Common Module Usage

The `common` module **must be included at the top of all environment `main.tf` files**. It provides standardized naming, tags, and region mappings.

```hcl
module "common" {
  source = "../../modules/common"

  identifier  = var.identifier
  environment = var.environment
  location    = var.location
}
```

### Common Module Outputs
- `naming_prefix` - Computed prefix: `{identifier}-{environment}-{region_abbrev}`
- `region_abbrev` - Short region code (e.g., `eus2`)
- `tags` - Standard tags for all resources

---

## Essential Code Examples

### Default VM Size
Use `Standard_B2ms` as the default VM size for node pools:

```hcl
variable "system_node_vm_size" {
  description = "VM size for system node pool"
  type        = string
  default     = "Standard_B2ms"
}
```

### Workload Identity Configuration

```hcl
resource "azurerm_kubernetes_cluster" "main" {
  name                = "aks-${module.common.naming_prefix}"
  # ... other config

  oidc_issuer_enabled       = true
  workload_identity_enabled = true
}

resource "azurerm_user_assigned_identity" "workload" {
  name                = "id-workload-${module.common.naming_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = module.common.tags
}

resource "azurerm_federated_identity_credential" "workload" {
  name                = "fed-workload-${module.common.naming_prefix}"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.workload.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.main.oidc_issuer_url
  subject             = "system:serviceaccount:${var.namespace}:${var.service_account}"
}
```

### Module Structure Pattern

```
modules/<module-name>/
├── main.tf           # Resource definitions
├── variables.tf      # Input variables
├── outputs.tf        # Output values
└── README.md         # Documentation
```

### Variable Definition Pattern

```hcl
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "enable_feature" {
  description = "Enable optional feature"
  type        = bool
  default     = false
}

variable "sku" {
  description = "SKU tier for the resource"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be Basic, Standard, or Premium."
  }
}
```

---

## Quick Reference Commands

```bash
# Initialize
terraform init

# Format
terraform fmt -recursive

# Validate
terraform validate

# Plan
terraform plan -var-file=<env>.tfvars

# Apply
terraform apply -var-file=<env>.tfvars

# TFLint
tflint --init && tflint --recursive
```

---

## Reference Documentation

- [AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [AKS Cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster)
- [Azure CAF Naming](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [TFLint AzureRM](https://github.com/terraform-linters/tflint-ruleset-azurerm)
