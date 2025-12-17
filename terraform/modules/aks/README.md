# AKS Module

This module creates an Azure Kubernetes Service (AKS) cluster with:

- System node pool (critical addons only)
- Workload node pool (optional spot instances)
- Managed identities (kubelet and workload)
- Azure CNI Overlay networking
- Azure AD RBAC integration
- Workload Identity support
- Container Insights monitoring
- Key Vault Secrets Provider

## Usage

```hcl
module "aks" {
  source = "../../modules/aks"

  resource_group_name = module.networking.resource_group_name
  location            = module.networking.resource_group_location
  
  cluster_name       = "aks-microservices-dev-wus3"
  dns_prefix         = "aks-microservices-dev"
  kubernetes_version = "1.30"
  
  aks_subnet_id              = module.networking.aks_subnet_id
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  
  # Identities
  kubelet_identity_name  = "id-aks-kubelet-dev-wus3"
  workload_identity_name = "id-aks-workload-dev-wus3"
  
  # System node pool
  system_node_count     = 2
  system_node_min_count = 2
  system_node_max_count = 3
  system_node_vm_size   = "Standard_B2ms"
  
  # Workload node pool
  workload_node_count     = 2
  workload_node_min_count = 1
  workload_node_max_count = 4
  workload_node_vm_size   = "Standard_B2ms"
  workload_node_spot      = true
  
  tags = {
    Environment = "dev"
    Owner       = "platform-team"
    ManagedBy   = "terraform"
  }
}
```

## Node Pool Architecture

| Pool | Purpose | VM Size | Scaling | Priority |
|------|---------|---------|---------|----------|
| system | CoreDNS, metrics-server, kube-proxy | Standard_B2ms | 2-3 nodes | Regular |
| workload | Application pods | Standard_B2ms | 1-4 nodes | Spot |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| resource_group_name | Name of the resource group | string | - | yes |
| location | Azure region | string | - | yes |
| cluster_name | Name of the AKS cluster | string | - | yes |
| dns_prefix | DNS prefix for the cluster | string | - | yes |
| kubernetes_version | Kubernetes version | string | "1.30" | no |
| aks_subnet_id | ID of the AKS subnet | string | - | yes |
| log_analytics_workspace_id | ID of Log Analytics workspace | string | - | yes |
| kubelet_identity_name | Name of kubelet identity | string | - | yes |
| workload_identity_name | Name of workload identity | string | - | yes |
| system_node_count | Initial system node count | number | 2 | no |
| system_node_min_count | Minimum system nodes | number | 2 | no |
| system_node_max_count | Maximum system nodes | number | 3 | no |
| system_node_vm_size | System node VM size | string | "Standard_B2ms" | no |
| workload_node_count | Initial workload node count | number | 2 | no |
| workload_node_min_count | Minimum workload nodes | number | 1 | no |
| workload_node_max_count | Maximum workload nodes | number | 4 | no |
| workload_node_vm_size | Workload node VM size | string | "Standard_B2ms" | no |
| workload_node_spot | Use spot instances | bool | true | no |
| admin_group_object_ids | Azure AD admin group IDs | list(string) | [] | no |
| tags | Resource tags | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | ID of the AKS cluster |
| cluster_name | Name of the AKS cluster |
| cluster_fqdn | FQDN of the AKS cluster |
| oidc_issuer_url | OIDC issuer URL for workload identity |
| node_resource_group | Name of the node resource group |
| kubelet_identity_* | Kubelet identity properties |
| workload_identity_* | Workload identity properties |

## Network Configuration

- **CNI**: Azure CNI Overlay
- **Pod CIDR**: 10.244.0.0/16
- **Service CIDR**: 10.245.0.0/16
- **DNS Service IP**: 10.245.0.10

## Security Features

- Azure AD RBAC enabled
- Workload Identity enabled
- Azure Policy addon enabled
- Key Vault Secrets Provider with auto-rotation
- Ephemeral OS disks for enhanced security
