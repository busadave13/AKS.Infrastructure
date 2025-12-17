# GitOps Module

This module configures GitOps with Flux v2 for AKS including:

- Flux extension installation
- Infrastructure configuration sync
- Applications configuration sync
- Helm releases configuration sync (optional)

## Usage

```hcl
module "gitops" {
  source = "../../modules/gitops"

  aks_cluster_id = module.aks.cluster_id
  environment    = "dev"
  
  # Git repository (separate from infrastructure repo)
  gitops_repo_url = "https://github.com/org/AKS.GitOps"
  gitops_branch   = "main"
  git_https_user  = "git"
  git_https_pat   = var.gitops_pat
  
  # Sync settings
  sync_interval_seconds  = 60
  retry_interval_seconds = 60
  
  # Configuration toggles
  enable_infrastructure_config = true
  enable_apps_config           = true
  enable_helm_releases_config  = false
  
  # Controller settings
  enable_helm_controller         = true
  enable_notification_controller = true
  enable_image_automation        = false
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| aks_cluster_id | ID of the AKS cluster | string | - | yes |
| environment | Environment name | string | - | yes |
| gitops_repo_url | URL of the GitOps repository | string | - | yes |
| gitops_branch | Branch to sync from | string | "main" | no |
| git_https_user | HTTPS username for Git | string | "git" | no |
| git_https_pat | Personal Access Token | string | - | yes |
| sync_interval_seconds | Sync interval | number | 60 | no |
| retry_interval_seconds | Retry interval | number | 60 | no |
| enable_infrastructure_config | Enable infrastructure config | bool | true | no |
| enable_apps_config | Enable apps config | bool | true | no |
| enable_helm_releases_config | Enable Helm releases | bool | false | no |
| enable_helm_controller | Enable Helm controller | bool | true | no |
| enable_notification_controller | Enable notifications | bool | true | no |
| enable_image_automation | Enable image automation | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| flux_extension_id | ID of the Flux extension |
| flux_extension_name | Name of the Flux extension |
| flux_namespace | Namespace where Flux is installed |
| infrastructure_config_id | ID of infrastructure configuration |
| apps_config_id | ID of apps configuration |
| helm_releases_config_id | ID of Helm releases configuration |

## GitOps Repository Structure

This module is designed to sync from a **separate GitOps repository** (not this infrastructure repository). This separation provides:
- **Independent versioning**: Kubernetes manifests can be updated without changing infrastructure code
- **Access control**: Different teams can have different permissions for infrastructure vs. application configs
- **Release management**: Application deployments can follow their own release cadence

The module expects the following structure at the root of your GitOps repository:

```
AKS.GitOps/                          # Separate repository
├── infrastructure/
│   ├── base/
│   │   ├── namespaces/
│   │   ├── rbac/
│   │   ├── network-policies/
│   │   └── kustomization.yaml
│   └── overlays/
│       ├── dev/
│       │   └── kustomization.yaml
│       ├── staging/
│       │   └── kustomization.yaml
│       └── prod/
│           └── kustomization.yaml
├── apps/
│   ├── base/
│   │   └── kustomization.yaml
│   └── overlays/
│       ├── dev/
│       ├── staging/
│       └── prod/
└── helm-releases/
    ├── base/
    │   └── sources/
    └── overlays/
        ├── dev/
        ├── staging/
        └── prod/
```

## Flux Controllers

| Controller | Purpose | Default |
|------------|---------|---------|
| source-controller | Fetches from Git/Helm repos | Enabled |
| kustomize-controller | Applies Kustomize manifests | Enabled |
| helm-controller | Manages Helm releases | Enabled |
| notification-controller | Sends alerts/notifications | Enabled |
| image-automation-controller | Auto-updates images | Disabled |
| image-reflector-controller | Scans container registries | Disabled |

## Security

- PAT is base64 encoded before transmission
- Consider storing PAT in Azure Key Vault
- Use minimal permissions for Git access
- Enable branch protection on GitOps repo

## Troubleshooting

```bash
# Check Flux extension status
az k8s-extension show \
  --cluster-name <aks-name> \
  --resource-group <rg-name> \
  --cluster-type managedClusters \
  --name flux

# Check Flux configurations
kubectl get gitrepositories -n flux-system
kubectl get kustomizations -n flux-system

# View controller logs
kubectl logs -n flux-system deployment/source-controller
kubectl logs -n flux-system deployment/kustomize-controller
