# Technical Context: AKS.Infrastructure

## Technology Stack Details

### Terraform Configuration
- **Version**: 1.6.0+
- **Backend**: Azure Storage Account (azurerm)
- **Provider**: AzureRM 4.52.0 (pinned in provider.tf)
- **State File**: `aks-staging.terraform.tfstate`
- **Provider Location**: `terraform/environments/staging/provider.tf` (separated from main.tf)

### Naming Convention
CAF-style naming with optional instance support:
```
{resource-type}[-{instance}]-{identifier}-{environment}-{region-abbreviation}
```

| Component | Description | Example |
|-----------|-------------|---------|
| resource-type | Azure resource prefix | `rg`, `aks`, `kv` |
| instance | Optional numeric ID | `01`, `02` (omit for singletons) |
| identifier | Project identifier | `xpci` |
| environment | Environment name | `staging` |
| region-abbreviation | Short region code | `wus2` |

### Azure Resources (Staging Environment)

| Resource | Name Pattern | SKU/Tier |
|----------|--------------|----------|
| Resource Group | `rg-xpci-staging-wus2` | N/A |
| Node Resource Group | `rg-aks-nodes-xpci-staging-wus2` | N/A (Azure-managed) |
| Virtual Network | `vnet-xpci-staging-wus2` | 10.1.0.0/16 |
| AKS Cluster | `aks-xpci-staging-wus2` | Free tier |
| System Node Pool | `system` | Standard_B2ms (2 nodes) |
| Workload Node Pool | `workload` | Standard_B2ms (2 nodes) |
| Container Registry | `crxpcistagingwus2` | Basic |
| Key Vault | `kv-xpci-staging-wus2` | Standard |
| Monitor Workspace | `amw-xpci-staging-wus2` | Pay-as-you-go |
| Managed Grafana | `graf-xpci-staging-wus2` | Standard |

### Network Configuration
| Subnet | CIDR | Purpose |
|--------|------|---------|
| snet-system | 10.1.0.0/23 | AKS system node pool |
| snet-workload | 10.1.2.0/23 | AKS workload node pool |
| snet-private | 10.1.4.0/24 | Private endpoints |
| Pod Network (Overlay) | 10.244.0.0/16 | Kubernetes pods |
| Service Network | 10.245.0.0/16 | Kubernetes services |

### AKS Configuration
- **Kubernetes Version**: 1.32.x (latest stable)
- **Network Plugin**: Azure CNI Overlay
- **Network Policy**: Azure
- **Availability Zones**: 1, 2, 3
- **OIDC Issuer**: Enabled
- **Workload Identity**: Enabled
- **CSI Secrets Store Driver**: Enabled

### Terraform Modules

| Module | Purpose | Key Resources |
|--------|---------|---------------|
| `common` | Naming, tags, region mappings | Standardized outputs for all modules |
| `networking` | VNet, Subnets, NSG, DNS | Virtual network infrastructure |
| `aks` | AKS cluster, Node pools, Identities | Kubernetes cluster |
| `acr` | Container Registry, Private endpoint | Image storage |
| `keyvault` | Key Vault, Private endpoint | Secrets management |
| `monitoring` | Azure Monitor, Grafana | Observability stack |
| `gitops` | Flux extension, Configurations | GitOps deployment |

### Common Module Outputs
| Output | Description |
|--------|-------------|
| `naming_prefix` | `{identifier}-{environment}-{region_abbreviation}` |
| `region_abbreviation` | Short region code (e.g., `wus2`) |
| `tags` | Standard tags for all resources |
| `identifier` | Project identifier |
| `environment` | Environment name |
| `location` | Azure region |

### GitOps Configuration
- **Tool**: Flux v2 (AKS extension)
- **Repository**: Separate repository (K8.Infra.GitOps)
- **Branch**: `staging`
- **Sync Interval**: 60 seconds
- **Controllers Enabled**:
  - source-controller
  - kustomize-controller
  - helm-controller
  - notification-controller

### CI/CD Pipeline
- **Platform**: GitHub Actions
- **Workflow Files**:
  - `.github/workflows/terraform.yml` - Main CI/CD
  - `.github/workflows/terraform-drift.yml` - Drift detection
- **Authentication**: OIDC (OpenID Connect) with Azure AD
- **Stages**: Validate → Plan → Apply
- **Required Secrets**:
  - `AZURE_CLIENT_ID`
  - `AZURE_TENANT_ID`
  - `AZURE_SUBSCRIPTION_ID`

### Drift Detection
- **Schedule**: Weekly (Sunday 8:00 AM UTC)
- **Behavior**: Creates/updates GitHub issues when drift detected
- **Labels**: `drift-detected`, `infrastructure`, `staging`

## Development Dependencies
- Azure CLI
- Terraform CLI (1.6.0+)
- kubectl
- Helm (optional)
- Git
- GitHub CLI (optional, for workflow management)

## Important File Locations
| File | Purpose |
|------|---------|
| `.clinerules/terraform-rules.md` | Terraform coding standards |
| `terraform/environments/staging/main.tf` | Root module for staging environment |
| `terraform/environments/staging/provider.tf` | Provider configuration |
| `terraform/environments/staging/variables.tf` | Variable definitions |
| `terraform/environments/staging/staging.tfvars` | Variable values |
| `terraform/environments/staging/backend.tf` | State backend config |
| `terraform/modules/common/` | Common naming and tags module |
| `.github/workflows/terraform.yml` | GitHub Actions CI/CD pipeline |
| `.github/workflows/terraform-drift.yml` | Drift detection workflow |
