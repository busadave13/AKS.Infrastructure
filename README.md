# AKS Infrastructure

Terraform Infrastructure as Code for Azure Kubernetes Service (AKS) dev cluster.

## Architecture Overview

This repository contains Terraform configurations for deploying a cost-optimized AKS dev cluster with the following features:

- **Region**: West US 2
- **Authentication**: Azure AD (Entra ID) with Azure RBAC
- **API Server**: Public access
- **GitOps**: Flux v2 add-on enabled for declarative deployments
- **Node Pools**: 
  - System pool: 1x Standard_B2ms (dedicated for system pods)
  - User pool: 1-2x Standard_B2ms with Spot instances for cost savings
- **Container Registry**: Azure Container Registry (Basic SKU)
- **Monitoring**: Container Insights with Log Analytics

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                     Azure Resource Group                         │
│                    rg-aks-dev-westus2                            │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │                 Virtual Network                          │    │
│  │              vnet-aks-dev (10.224.0.0/16)               │    │
│  │                                                          │    │
│  │  ┌─────────────────────────────────────────────────┐    │    │
│  │  │         AKS Subnet (10.224.0.0/20)              │    │    │
│  │  │                                                  │    │    │
│  │  │  ┌─────────────────────────────────────────┐   │    │    │
│  │  │  │         AKS Cluster                      │   │    │    │
│  │  │  │        aks-dev-westus2                   │   │    │    │
│  │  │  │                                          │   │    │    │
│  │  │  │  • System Node Pool (1x B2ms)           │   │    │    │
│  │  │  │  • User Node Pool (1-2x B2ms Spot)      │   │    │    │
│  │  │  │  • GitOps (Flux v2) Add-on              │   │    │    │
│  │  │  │  • Azure CNI Overlay                     │   │    │    │
│  │  │  │  • Azure AD + Azure RBAC                │   │    │    │
│  │  │  │                                          │   │    │    │
│  │  │  └──────────────────────────────────────────┘   │    │    │
│  │  └─────────────────────────────────────────────────┘    │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                  │
│  ┌─────────────────┐    ┌─────────────────────────────┐         │
│  │ Container       │    │ Log Analytics Workspace     │         │
│  │ Registry (Basic)│    │ (Container Insights)        │         │
│  └─────────────────┘    └─────────────────────────────┘         │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

## Project Structure

```
├── .github/
│   └── workflows/
│       ├── terraform-plan.yml   # PR validation and planning
│       └── terraform-apply.yml  # Deployment on merge
├── terraform/
│   ├── bootstrap/             # One-time setup for Workload Identity
│   │   ├── main.tf            # Azure AD app, federated credentials
│   │   ├── variables.tf       # Bootstrap variables
│   │   ├── outputs.tf         # GitHub configuration values
│   │   └── terraform.tfvars.example
│   ├── environments/
│   │   └── dev/
│   │       ├── main.tf        # Root module composition
│   │       ├── variables.tf   # Variable definitions
│   │       ├── outputs.tf     # Output values
│   │       ├── terraform.tfvars # Environment values
│   │       └── backend.tf     # State backend config
│   ├── modules/
│   │   ├── aks/              # AKS cluster module
│   │   ├── acr/              # Container registry module
│   │   ├── monitoring/       # Log Analytics module
│   │   └── networking/       # VNet and subnets module
│   └── shared/
│       └── versions.tf       # Provider constraints
└── README.md
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.6.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.50.0
- [GitHub CLI](https://cli.github.com/) (optional, for secret management)
- Azure subscription with Owner or Contributor access
- Permissions to create Azure AD applications (for Workload Identity setup)
- (Optional) Azure AD group for cluster admin access

## Authentication

This repository uses **Workload Identity (OIDC)** for secure, secretless authentication to Azure from GitHub Actions. This is more secure than using client secrets because:

- No secrets to manage, rotate, or potentially leak
- Tokens are short-lived and scoped to specific workflows
- Azure AD federated credentials validate the GitHub token issuer

### Authentication Flow

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│  GitHub Actions │         │   Azure AD      │         │     Azure       │
│    Workflow     │         │  (Entra ID)     │         │   Resources     │
└────────┬────────┘         └────────┬────────┘         └────────┬────────┘
         │                           │                           │
         │  1. Request OIDC Token    │                           │
         │  (with job claims)        │                           │
         ├──────────────────────────>│                           │
         │                           │                           │
         │  2. Validate federated    │                           │
         │     credential subject    │                           │
         │<──────────────────────────┤                           │
         │                           │                           │
         │  3. Exchange for Azure AD │                           │
         │     access token          │                           │
         ├──────────────────────────>│                           │
         │                           │                           │
         │  4. Use token to access   │                           │
         │     Azure resources       │                           │
         ├──────────────────────────────────────────────────────>│
         │                           │                           │
```

## Setup Guide

### Step 1: Bootstrap Azure Resources

The bootstrap configuration creates the necessary Azure AD resources for Workload Identity:

```bash
cd terraform/bootstrap

# Copy and configure variables
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values:
# - github_repository: "your-org/AKS.Infrastructure"
# - github_repository_name: "AKS.Infrastructure"
# - environment: "dev"

# Authenticate to Azure
az login

# Initialize and apply
terraform init
terraform plan
terraform apply
```

The bootstrap creates:
- Azure AD Application Registration
- Service Principal
- Federated Identity Credentials for:
  - Pull requests
  - Main branch pushes
  - GitHub environment deployments
- Azure Storage Account for Terraform state (with Azure AD auth)
- Required RBAC role assignments

### Step 2: Configure GitHub Repository

After running the bootstrap, configure GitHub with the output values:

**Option A: Using GitHub CLI (Recommended)**

The bootstrap outputs a ready-to-use script:

```bash
# View the configuration commands
terraform output github_cli_commands

# Run the commands (example):
gh secret set AZURE_CLIENT_ID --body "<client-id>"
gh secret set AZURE_TENANT_ID --body "<tenant-id>"
gh secret set AZURE_SUBSCRIPTION_ID --body "<subscription-id>"

gh variable set TF_STATE_RESOURCE_GROUP --body "rg-terraform-state-dev"
gh variable set TF_STATE_STORAGE_ACCOUNT --body "<storage-account-name>"
gh variable set TF_STATE_CONTAINER --body "tfstate"
```

**Option B: Using GitHub Web UI**

1. Go to **Settings** → **Secrets and variables** → **Actions**
2. Add the following **Secrets**:
   - `AZURE_CLIENT_ID`: Application (Client) ID from bootstrap output
   - `AZURE_TENANT_ID`: Azure AD Tenant ID from bootstrap output
   - `AZURE_SUBSCRIPTION_ID`: Azure Subscription ID from bootstrap output
3. Add the following **Variables**:
   - `TF_STATE_RESOURCE_GROUP`: Resource group name from bootstrap output
   - `TF_STATE_STORAGE_ACCOUNT`: Storage account name from bootstrap output
   - `TF_STATE_CONTAINER`: `tfstate`

### Step 3: Create GitHub Environment (Optional but Recommended)

For environment-specific deployments with protection rules:

1. Go to **Settings** → **Environments** → **New environment**
2. Create environment named `dev`
3. Add the same secrets to the environment
4. (Optional) Configure protection rules:
   - Required reviewers for production environments
   - Wait timer for staged deployments

### Step 4: Configure Infrastructure Variables

```bash
cd terraform/environments/dev

# The terraform.tfvars should already exist
# Update it with your specific values:
```

Edit `terraform/environments/dev/terraform.tfvars`:

```hcl
# Update the ACR name to be globally unique
acr_name = "acryourorgdevwestus2"

# Add your Azure AD group object IDs for cluster admin access
admin_group_object_ids = ["<your-aad-group-object-id>"]
```

### Step 5: Deploy

Push changes to trigger the CI/CD pipeline:

```bash
# Create a feature branch
git checkout -b feature/initial-deployment

# Commit your changes
git add .
git commit -m "Configure infrastructure deployment"

# Push and create PR
git push -u origin feature/initial-deployment
gh pr create --title "Initial AKS deployment" --body "Deploy AKS cluster"
```

The PR will show a Terraform plan in the comments. After review and merge, the apply workflow will deploy the infrastructure.

## CI/CD Pipeline

### Terraform Plan Workflow (`.github/workflows/terraform-plan.yml`)

Triggered on:
- Pull requests to `main` branch
- Manual workflow dispatch

Features:
- Format validation
- Terraform validate
- Plan output as PR comment
- Artifact upload for plan file

### Terraform Apply Workflow (`.github/workflows/terraform-apply.yml`)

Triggered on:
- Push to `main` branch (merge)
- Manual workflow dispatch

Features:
- Uses OIDC for secure authentication
- Concurrency control (one deployment at a time)
- Plan with detailed exit codes
- Automatic apply on changes
- Artifact retention for audit

### GitHub Secrets and Variables

| Type | Name | Description |
|------|------|-------------|
| Secret | `AZURE_CLIENT_ID` | Azure AD Application (Client) ID |
| Secret | `AZURE_TENANT_ID` | Azure AD Tenant ID |
| Secret | `AZURE_SUBSCRIPTION_ID` | Azure Subscription ID |
| Variable | `TF_STATE_RESOURCE_GROUP` | Terraform state resource group |
| Variable | `TF_STATE_STORAGE_ACCOUNT` | Terraform state storage account |
| Variable | `TF_STATE_CONTAINER` | Terraform state container name |

## Connect to the Cluster

After deployment:

```bash
# Get credentials
az aks get-credentials --resource-group rg-aks-dev-westus2 --name aks-aks-dev-westus2

# Verify connection
kubectl get nodes
```

## GitOps with Flux

The cluster comes with Flux v2 pre-installed. To configure a GitOps repository:

```bash
# Create a Flux GitRepository source
kubectl apply -f - <<EOF
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: my-app
  namespace: flux-system
spec:
  interval: 1m
  url: https://github.com/your-org/your-gitops-repo
  ref:
    branch: main
EOF

# Create a Kustomization to deploy from the repo
kubectl apply -f - <<EOF
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: my-app
  namespace: flux-system
spec:
  interval: 10m
  sourceRef:
    kind: GitRepository
    name: my-app
  path: ./clusters/dev
  prune: true
EOF
```

## Estimated Monthly Cost

| Resource | Cost (Est.) |
|----------|-------------|
| AKS System Pool (1x B2ms) | ~$60 |
| AKS User Pool (1x B2ms Spot) | ~$15-20 |
| Container Registry (Basic) | ~$5 |
| Log Analytics (5GB/day free) | ~$0-10 |
| Storage Account (State) | ~$1 |
| **Total** | **~$80-95/month** |

## Deploying Istio with GitOps

Since the cluster uses GitOps instead of the Istio add-on, you can deploy Istio via Flux:

1. Add the Istio Helm repository as a source
2. Create a HelmRelease for Istio base and istiod
3. Configure Istio ingress gateway

Example Flux configuration for Istio is available in the [Istio documentation](https://istio.io/latest/docs/setup/install/helm/).

## Troubleshooting

### Workflow fails with authentication error

Ensure:
1. Federated credentials are correctly configured in Azure AD
2. The subject claim matches (repo, branch, or environment)
3. GitHub secrets have the correct values

```bash
# Verify the Azure AD app configuration
az ad app federated-credential list --id <app-id>
```

### Cannot connect to cluster

```bash
# Ensure you're logged in
az login

# Get fresh credentials
az aks get-credentials --resource-group rg-aks-dev-westus2 --name aks-aks-dev-westus2 --overwrite-existing
```

### Terraform state access denied

If the GitHub Actions workflow fails with state access denied:
1. Verify the service principal has `Storage Blob Data Contributor` role on the storage account
2. Check that the federated credential subjects match the workflow context

```bash
# Verify role assignments for the service principal
az role assignment list --assignee <service-principal-object-id> \
  --scope /subscriptions/<sub-id>/resourceGroups/rg-terraform-state-dev
```

### Spot nodes not scheduling pods

Spot nodes have a taint. Add tolerations to your workloads:

```yaml
tolerations:
- key: "kubernetes.azure.com/scalesetpriority"
  operator: "Equal"
  value: "spot"
  effect: "NoSchedule"
```

### Flux not syncing

```bash
# Check Flux status
kubectl get kustomizations -A
kubectl get gitrepositories -A

# Check Flux logs
kubectl logs -n flux-system deployment/source-controller
kubectl logs -n flux-system deployment/kustomize-controller
```

## Security Considerations

### Workload Identity Best Practices

1. **Scope federated credentials narrowly**: Only allow specific branches/environments
2. **Use GitHub Environments**: Add protection rules for production deployments
3. **Review role assignments**: Grant minimum required permissions
4. **Enable Azure AD sign-in logs**: Monitor for suspicious activity

### Storage Account Security

The Terraform state storage account is configured with:
- Azure AD authentication only (no shared keys)
- TLS 1.2 minimum
- Blob versioning enabled
- Soft delete for recovery
- No public blob access

## Contributing

1. Create a feature branch
2. Make changes
3. Run `terraform fmt -recursive` to format code
4. Create a pull request
5. Review the Terraform plan in PR comments
6. Merge to main to apply changes

## License

MIT
