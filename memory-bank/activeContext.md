# Active Context

## Current Focus
**Completed**: Consolidated AKS networking infrastructure, simplified node pool configuration, and updated naming conventions.

## Recent Changes (December 23, 2025)

### 1. Identifier and DNS Label Update
Changed project identifier and ingress DNS configuration:

- **Identifier**: Changed from `xpci` to `azr`
- **Ingress DNS Label**: Now uses `var.identifier` (dynamic) instead of hardcoded value
- **FQDN**: `azr.westus2.cloudapp.azure.com`
- **All resource names** now use `azr-staging-wus2` pattern

### 2. Networking Infrastructure Consolidation
Replaced separate system/workload subnets with a unified cluster subnet:

- **Single Cluster Subnet**: Both system and compute node pools now use `snet-cluster-*` (10.1.0.0/22)
- **Updated NSG Rules**: Fixed `destination_address_prefix = "*"` to allow Azure LB DNAT'd traffic
- **Ingress Ports**: 80 (HTTP), 443 (HTTPS), 15021 (Istio health), 30000-32767 (NodePort range)

### 3. Node Pool Renaming
Renamed "workload" node pool to "compute" for clarity:

- `workload_node_*` → `compute_node_*` in all modules and environments
- Removed `enable_workload_node_pool` toggle - compute node pool is now always created
- Two-node-pool architecture is now standard (no single-node mode)

### 4. Removed Dev Environment
- Deleted `terraform/environments/dev/` directory
- Only staging environment remains for development/testing

### Files Modified
**Modules:**
- `terraform/modules/networking/` - Unified cluster subnet with NSG
- `terraform/modules/aks/variables.tf` - Renamed workload to compute
- `terraform/modules/aks/main.tf` - Renamed node pool, removed conditional
- `terraform/modules/aks/outputs.tf` - Updated outputs for compute pool

**Environments:**
- `terraform/environments/staging/variables.tf` - Renamed variables
- `terraform/environments/staging/main.tf` - Updated module calls
- `terraform/environments/staging/parameters.tfvars` - Updated parameters

## Architecture

```
VNet: 10.1.0.0/16
├── snet-cluster: 10.1.0.0/22 (1022 IPs for all AKS nodes)
│   ├── system node pool (1 node, Standard_D4as_v5)
│   └── compute node pool (1 node, Standard_B4ms)
└── snet-private: 10.1.4.0/24 (private endpoints)

NSG: nsg-cluster-*
├── AllowHTTPInbound (80) → *
├── AllowHTTPSInbound (443) → *
├── AllowIstioHealthInbound (15021) → *
├── AllowNodePortInbound (30000-32767) → *
└── Default Azure rules
```

## GitHub Actions Workflow Updates (December 23, 2025)

### terraform.yml Changes
- **Removed push trigger** - No longer runs on merge to main
- **Simplified workflow_dispatch** - Only `apply` and `destroy` options (no plan-only)
- **Always runs apply** - When triggered manually, runs validate → plan → apply with environment approval
- **Removed dev environment** - Only staging remains

### Workflow Flow
```
Manual Trigger (workflow_dispatch)
    ↓
validate → plan → apply (requires staging environment approval)
```

### terraform-drift.yml Fix
- Corrected tfvars filename from `staging.tfvars` to `parameters.tfvars`

## Pending Actions
1. **User must commit/push changes** and apply via CI/CD pipeline
2. **Terraform apply will recreate AKS cluster** (subnet is immutable)
3. **GitOps (Flux) will restore** Istio, Gateway, and applications
4. **Test ingress**: `curl http://azr.westus2.cloudapp.azure.com`

## Key Technical Details
- Azure CNI Overlay networking with single subnet for all node pools
- Pod CIDR: 10.244.0.0/16 (overlay network)
- Service CIDR: 10.245.0.0/16
- Kubernetes version: 1.32
