# Technical Context: AKS.Infrastructure

## Technology Stack Details

### Terraform Configuration
- **Version**: 1.6.0+
- **Backend**: Azure Storage Account (azurerm)
- **Provider**: AzureRM 4.52.0 (pinned in root module)
- **State File**: `aks-dev.terraform.tfstate`
- **Version Management**: Centralized in `terraform/environments/dev/main.tf` (no versions.tf in modules)

### Azure Resources (Development Environment)

| Resource | Name Pattern | SKU/Tier |
|----------|--------------|----------|
| Resource Group | `rg-aks-dev-wus2` | N/A |
| Node Resource Group | `rg-aks-nodepool-dev-wus2` | N/A (Azure-managed) |
| Virtual Network | `vnet-aks-dev-wus2` | 10.0.0.0/16 |
| AKS Cluster | `aks-dev-wus2` | Free tier |
| System Node Pool | `system` | Standard_B2ms (2 nodes) |
| Workload Node Pool | `workload` | Standard_B2ms (2 nodes) |
| Container Registry | `acraksdevwus2` | Basic |
| Key Vault | `kv-aks-dev-wus2` | Standard |
| Log Analytics | `log-aks-dev-wus2` | Pay-as-you-go |
| Monitor Workspace | `amw-aks-dev-wus2` | Pay-as-you-go |
| Managed Grafana | `grafana-aks-dev-wus2` | Essential |

### Network Configuration
| Subnet | CIDR | Purpose |
|--------|------|---------|
| snet-aks-nodes | 10.0.0.0/22 | AKS node pool nodes |
| snet-privateendpoints | 10.0.4.0/24 | Private endpoints |
| Pod Network (Overlay) | 10.244.0.0/16 | Kubernetes pods |
| Service Network | 10.245.0.0/16 | Kubernetes services |

### AKS Configuration
- **Kubernetes Version**: 1.30.x (latest stable)
- **Network Plugin**: Azure CNI Overlay
- **Network Policy**: Azure
- **Availability Zones**: 1, 2, 3
- **OIDC Issuer**: Enabled
- **Workload Identity**: Enabled
- **CSI Secrets Store Driver**: Enabled

### Terraform Modules

| Module | Purpose | Key Resources |
|--------|---------|---------------|
| `networking` | VNet, Subnets, NSG | Virtual network infrastructure |
| `aks` | AKS cluster, Node pools | Kubernetes cluster |
| `acr` | Container Registry | Image storage |
| `keyvault` | Key Vault | Secrets management |
| `monitoring` | Log Analytics, Prometheus, Grafana | Observability stack |
| `gitops` | Flux extension, Configurations | GitOps deployment |

### GitOps Configuration
- **Tool**: Flux v2 (AKS extension)
- **Repository**: Separate repository (AKS.GitOps)
- **Sync Interval**: 60 seconds
- **Controllers Enabled**:
  - source-controller
  - kustomize-controller
  - helm-controller
  - notification-controller

### CI/CD Pipeline
- **Platform**: GitHub Actions
- **Workflow File**: `.github/workflows/terraform.yml`
- **Authentication**: OIDC (OpenID Connect) with Azure AD
- **Stages**: Validate → Plan → Apply
- **Required Secrets**:
  - `AZURE_CLIENT_ID`
  - `AZURE_TENANT_ID`
  - `AZURE_SUBSCRIPTION_ID`

## Development Dependencies
- Azure CLI
- Terraform CLI (1.6.0+)
- kubectl
- Helm (optional)
- Git

## Important File Locations
| File | Purpose |
|------|---------|
| `docs/architecture-design.md` | Complete architecture documentation |
| `terraform/environments/dev/main.tf` | Root module for dev environment |
| `terraform/environments/dev/variables.tf` | Variable definitions |
| `terraform/environments/dev/backend.tf` | State backend config |
| `.github/workflows/terraform.yml` | GitHub Actions CI/CD pipeline |
