# AKS Infrastructure Platform

Production-ready Azure Kubernetes Service (AKS) infrastructure using Terraform, GitOps with Flux v2, and GitHub Actions CI/CD.

## Architecture Overview

This repository implements a complete AKS platform with:

- **AKS Cluster** with system and workload node pools (Linux only)
- **Azure Container Registry (ACR)** for container images
- **Azure Key Vault** for secrets management
- **Azure Monitor** with Log Analytics, Managed Prometheus, and Managed Grafana
- **GitOps** with Flux v2 for Kubernetes configuration management
- **Network Security** with NSGs and default-deny network policies

## Project Structure

```
.
├── .github/
│   └── workflows/
│       ├── terraform.yml           # Main CI/CD workflow
│       └── terraform-drift.yml     # Drift detection workflow
├── terraform/
│   ├── environments/
│   │   └── staging/                # Staging environment
│   │       ├── main.tf             # Module composition
│   │       ├── variables.tf        # Variable definitions
│   │       ├── staging.tfvars      # Variable values
│   │       ├── outputs.tf          # Output definitions
│   │       ├── backend.tf          # State backend config
│   │       └── provider.tf         # Provider configuration
│   ├── modules/
│   │   ├── common/                 # Tags, naming, region mappings
│   │   ├── networking/             # VNet, subnets, NSG, DNS
│   │   ├── aks/                    # AKS cluster and node pools
│   │   ├── acr/                    # Container registry
│   │   ├── keyvault/               # Key Vault
│   │   ├── monitoring/             # Log Analytics, Prometheus, Grafana
│   │   └── gitops/                 # Flux extension and configuration
│   └── .tflint.hcl                 # TFLint configuration
└── README.md
```

> **Note**: GitOps configuration (Kubernetes manifests) is maintained in a separate repository for independent versioning.

## Prerequisites

- Azure subscription with Owner or Contributor access
- Azure CLI installed and authenticated (`az login`)
- Terraform >= 1.6.0
- kubectl
- GitHub repository with Actions enabled

## Naming Convention

This project follows Azure CAF (Cloud Adoption Framework) naming conventions:

```
{resource-type}[-{instance}]-{identifier}-{environment}-{region-abbreviation}
```

| Component | Description | Example |
|-----------|-------------|---------|
| resource-type | Azure resource prefix | `rg`, `aks`, `kv`, `vnet` |
| instance | Optional numeric ID for multiple instances | `01`, `02` |
| identifier | Project/workload identifier | `xpci`, `xbs` |
| environment | Environment name | `dev`, `staging`, `prod` |
| region-abbreviation | Short region code | `eus2`, `wus2` |

**Examples:**
- Resource Group: `rg-xpci-staging-wus2`
- AKS Cluster: `aks-xpci-staging-wus2`
- Key Vault: `kv-xpci-staging-wus2`
- Container Registry: `crxpcistagingwus2` (no hyphens)

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/busadave13/AKS.Infra.git
cd AKS.Infra
```

### 2. Configure Variables

Edit `terraform/environments/staging/staging.tfvars`:

```hcl
# Required: Project identifier for resource naming
identifier  = "xpci"
location    = "westus2"
environment = "staging"

tags = {
  Owner       = "platform-team"
  CostCenter  = "IT-1234"
  Application = "aks-microservices"
}

# Add your Azure AD object IDs
aks_admin_group_object_ids = ["your-azure-ad-group-id"]
grafana_admin_object_ids   = ["your-azure-ad-user-id"]
```

### 3. Deploy Infrastructure

```bash
# Navigate to environment directory
cd terraform/environments/staging

# Initialize Terraform
terraform init

# Review the plan
terraform plan -var-file=staging.tfvars

# Apply the configuration
terraform apply -var-file=staging.tfvars
```

### 4. Connect to the Cluster

```bash
# Get credentials (using CAF naming)
az aks get-credentials \
  --resource-group rg-xpci-staging-wus2 \
  --name aks-xpci-staging-wus2

# Verify connection
kubectl get nodes
```

### 5. (Optional) Enable GitOps

After the initial deployment, enable GitOps:

1. Update `staging.tfvars`:
```hcl
enable_gitops   = true
gitops_repo_url = "https://github.com/your-org/gitops-config"
gitops_branch   = "staging"
```

2. Set the Git PAT:
```bash
export TF_VAR_gitops_pat="your-github-pat"
```

3. Apply changes:
```bash
terraform apply
```

## Module Reference

### Common Module
Provides standardized naming, tags, and region mappings.

| Output | Description |
|--------|-------------|
| `naming_prefix` | Computed prefix: `{identifier}-{environment}-{region_abbreviation}` |
| `region_abbreviation` | Short region code (e.g., `wus2`) |
| `tags` | Standard tags for all resources |

### Networking Module
Creates VNet, subnets, NSG, and private DNS zones.

| Output | Description |
|--------|-------------|
| `vnet_id` | Virtual Network ID |
| `system_subnet_id` | System node pool subnet ID |
| `workload_subnet_id` | Workload node pool subnet ID |
| `private_subnet_id` | Private endpoints subnet ID |

### AKS Module
Deploys AKS cluster with system and workload node pools.

| Output | Description |
|--------|-------------|
| `cluster_id` | AKS cluster resource ID |
| `cluster_name` | AKS cluster name |
| `oidc_issuer_url` | OIDC issuer for workload identity |

### Monitoring Module
Sets up Azure Monitor Workspace (Prometheus) and Managed Grafana.

| Output | Description |
|--------|-------------|
| `monitor_workspace_id` | Azure Monitor workspace ID |
| `monitor_workspace_name` | Azure Monitor workspace name |
| `grafana_endpoint` | Grafana dashboard URL |
| `grafana_id` | Grafana resource ID |

## CI/CD with GitHub Actions

### Setup OIDC Federation

GitHub Actions uses OpenID Connect (OIDC) to authenticate with Azure without storing credentials.

#### 1. Create Azure AD App Registration

```bash
# Create the app registration
az ad app create --display-name "github-oidc-aks-infrastructure"

# Get the app ID (save this)
az ad app list --display-name "github-oidc-aks-infrastructure" --query "[].appId" -o tsv
```

#### 2. Create Federated Credential

```bash
# Create federated credential for main branch
az ad app federated-credential create \
  --id <app-object-id> \
  --parameters '{
    "name": "github-main-branch",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:busadave13/AKS.Infrastructure:ref:refs/heads/main",
    "audiences": ["api://AzureADTokenExchange"]
  }'

# Create federated credential for pull requests
az ad app federated-credential create \
  --id <app-object-id> \
  --parameters '{
    "name": "github-pull-requests",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:busadave13/AKS.Infrastructure:pull_request",
    "audiences": ["api://AzureADTokenExchange"]
  }'
```

#### 3. Create Service Principal and Assign Roles

```bash
# Create service principal
az ad sp create --id <app-client-id>

# Assign Contributor role to subscription
az role assignment create \
  --assignee <app-client-id> \
  --role "Contributor" \
  --scope "/subscriptions/<subscription-id>"
```

#### 4. Configure Repository Secrets

In your GitHub repository, go to **Settings > Secrets and variables > Actions** and add:

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | Azure AD App Registration Client ID |
| `AZURE_TENANT_ID` | Azure AD Tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID |

#### 5. Create Terraform State Storage

```bash
az group create -n rg-terraform-state -l eastus2
az storage account create -n stterraformstate -g rg-terraform-state -l eastus2 --sku Standard_LRS
az storage container create -n tfstate --account-name stterraformstate
```

### Workflow Triggers

| Event | Behavior |
|-------|----------|
| Push to `main` | Validate → Plan |
| Pull Request to `main` | Validate → Plan (with PR comment) |
| Manual (`workflow_dispatch`) | Select action: plan, apply, or destroy |

### Drift Detection

The `terraform-drift.yml` workflow runs weekly to detect infrastructure drift:
- Scheduled: Every Sunday at 8:00 AM UTC
- Creates GitHub issues when drift is detected
- Updates existing issues if drift persists

### Manual Workflow Execution

Use the GitHub CLI or web interface to manually trigger workflows:

```bash
# Install GitHub CLI
winget install GitHub.cli

# Authenticate
gh auth login

# Trigger plan
gh workflow run terraform.yml -f action=plan -f environment=staging

# Trigger apply
gh workflow run terraform.yml -f action=apply -f environment=staging

# Trigger destroy (use with caution!)
gh workflow run terraform.yml -f action=destroy -f environment=staging

# Trigger drift detection
gh workflow run terraform-drift.yml -f environment=staging

# View workflow runs
gh run list --workflow=terraform.yml

# View workflow details
gh run view <run-id>

# View logs
gh run view <run-id> --log
```

## GitOps with Flux

> **Note**: GitOps configuration is maintained in a separate repository (e.g., `AKS.GitOps`).

### Recommended GitOps Repository Structure

```
AKS.GitOps/
├── clusters/
│   └── dev/
│       └── kustomization.yaml
├── infrastructure/
│   ├── base/
│   │   ├── namespaces/       # Namespace definitions
│   │   ├── rbac/             # RBAC policies
│   │   └── network-policies/ # Default deny policies
│   └── overlays/
│       └── dev/              # Dev-specific configs
└── apps/
    ├── base/
    │   └── sample-app/       # Sample application
    └── overlays/
        └── dev/              # Dev replica counts
```

### Monitoring GitOps

```bash
# Check sync status
kubectl get gitrepositories -n flux-system
kubectl get kustomizations -n flux-system

# View controller logs
kubectl logs -n flux-system deployment/kustomize-controller
```

## Security Features

- **Private AKS Cluster** (optional via `enable_private_endpoints`)
- **Workload Identity** for pod-level Azure access
- **Azure AD Integration** for cluster authentication
- **Network Policies** with default-deny rules
- **Key Vault** for secrets management
- **OIDC Federation** for passwordless GitHub Actions authentication

## Cost Optimization

- **Linux-only** node pools (no Windows overhead)
- **Spot instances** for workload nodes in dev
- **B-series VMs** for dev/test environments
- **Autoscaling** for right-sizing

## Useful Commands

```bash
# Get AKS credentials
az aks get-credentials -g <resource-group> -n <cluster-name>

# Check cluster health
kubectl get nodes
kubectl top nodes

# Login to ACR
az acr login --name <acr-name>

# View Terraform outputs
terraform output

# Force Flux reconciliation
kubectl annotate --overwrite gitrepository/flux-infrastructure \
  -n flux-system reconcile.fluxcd.io/requestedAt="$(date +%s)"
```

## Troubleshooting

### Terraform Issues

```bash
# Re-initialize with upgrade
terraform init -upgrade

# Unlock stuck state
terraform force-unlock <lock-id>

# Detailed logging
TF_LOG=DEBUG terraform apply
```

### AKS Issues

```bash
# Check node status
kubectl describe nodes

# Check system pods
kubectl get pods -n kube-system

# View cluster events
kubectl get events -A --sort-by='.lastTimestamp'
```

### Flux Issues

```bash
# Check Flux components
kubectl get pods -n flux-system

# Describe failed kustomization
kubectl describe kustomization <name> -n flux-system

# Check source controller
kubectl logs -n flux-system deployment/source-controller
```

### GitHub Actions Issues

```bash
# View workflow runs
gh run list --workflow=terraform.yml

# View failed run details
gh run view <run-id> --log-failed

# Re-run failed workflow
gh run rerun <run-id>
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - see [LICENSE](LICENSE) for details.
