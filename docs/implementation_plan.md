# Implementation Plan

> **Status: COMPLETED** (December 23, 2025)
> 
> All infrastructure changes have been implemented and are pending deployment via CI/CD.

[Overview]
Consolidate AKS networking to use a single cluster subnet and fix NSG rules to enable Istio Gateway API ingress traffic.

**Current Configuration:**
- **Identifier**: `azr`
- **Environment**: `staging`
- **Region**: `westus2`
- **FQDN**: `azr.westus2.cloudapp.azure.com`

This implementation addresses two key issues with the current AKS infrastructure:

1. **NSG blocking LoadBalancer traffic**: The current workload subnet NSG has `destination_address_prefix` set to the subnet CIDR (`10.1.2.0/23`), which blocks Azure Load Balancer traffic because DNAT'd packets arrive with the public IP as destination. This needs to be changed to `*` for HTTP/HTTPS and NodePort traffic.

2. **Subnet consolidation**: Currently there are separate subnets for system and workload node pools. This adds unnecessary complexity and doesn't provide meaningful isolation for the staging environment. Consolidating to a single `cluster-subnet` with CIDR `10.1.0.0/22` (1024 addresses) simplifies networking and avoids cross-subnet traffic issues.

**Note**: This change requires destroying and recreating the AKS cluster since subnet assignment is immutable. GitOps will restore application state after recreation.

[Types]
No new type definitions required - this is infrastructure-only changes.

The implementation involves Terraform variable modifications and resource restructuring. All existing variable types remain compatible; only default values and resource references change.

[Files]
Modifications to networking module, AKS module, and environment configurations.

**Modified Files:**

1. **`terraform/modules/networking/main.tf`**
   - Remove `azurerm_subnet.system` resource
   - Remove `azurerm_subnet.workload` resource  
   - Add new `azurerm_subnet.cluster` resource with CIDR `10.1.0.0/22`
   - Remove `azurerm_network_security_group.system` resource
   - Rename `azurerm_network_security_group.workload` to `azurerm_network_security_group.cluster`
   - Update NSG rules: change `destination_address_prefix` from subnet CIDR to `*`
   - Add NSG rules for: port 15021 (Istio health probe), ports 30000-32767 (NodePorts)
   - Remove `azurerm_subnet_network_security_group_association.system`
   - Rename `azurerm_subnet_network_security_group_association.workload` to `.cluster`

2. **`terraform/modules/networking/variables.tf`**
   - Remove `system_subnet_prefix` variable
   - Remove `workload_subnet_prefix` variable
   - Remove `system_nsg_name` variable
   - Remove `workload_nsg_name` variable
   - Add `cluster_subnet_prefix` variable
   - Add `cluster_nsg_name` variable

3. **`terraform/modules/networking/outputs.tf`**
   - Remove `system_subnet_id` output
   - Remove `system_subnet_name` output
   - Remove `system_nsg_id` output
   - Remove `workload_subnet_id` output
   - Remove `workload_subnet_name` output
   - Remove `workload_nsg_id` output
   - Add `cluster_subnet_id` output
   - Add `cluster_subnet_name` output
   - Add `cluster_nsg_id` output

4. **`terraform/modules/aks/main.tf`**
   - Update `default_node_pool.vnet_subnet_id` to use `var.cluster_subnet_id`
   - Update workload node pool `vnet_subnet_id` to use `var.cluster_subnet_id`

5. **`terraform/modules/aks/variables.tf`**
   - Remove `system_subnet_id` variable
   - Remove `workload_subnet_id` variable
   - Add `cluster_subnet_id` variable

6. **`terraform/environments/staging/main.tf`**
   - Update networking module: remove system/workload subnet params, add cluster subnet params
   - Update AKS module: replace `system_subnet_id` and `workload_subnet_id` with `cluster_subnet_id`

7. **`terraform/environments/staging/variables.tf`**
   - Remove `system_subnet_prefix` variable
   - Remove `workload_subnet_prefix` variable
   - Add `cluster_subnet_prefix` variable

8. **`terraform/environments/staging/parameters.tfvars`**
   - Remove `system_subnet_prefix = "10.1.0.0/23"` line
   - Remove `workload_subnet_prefix = "10.1.2.0/23"` line
   - Add `cluster_subnet_prefix = "10.1.0.0/22"` line

9. **`terraform/environments/dev/main.tf`**
   - Same updates as staging main.tf

10. **`terraform/environments/dev/variables.tf`**
    - Same updates as staging variables.tf

11. **`terraform/environments/dev/parameters.tfvars`**
    - Update subnet CIDR for dev environment (use `10.0.0.0/22`)

[Functions]
No function changes - Terraform resources only.

This implementation involves Terraform resource modifications, not function definitions. All changes are declarative infrastructure definitions.

[Classes]
No class changes - Terraform resources only.

This implementation involves Terraform resource modifications, not class definitions.

[Dependencies]
No new dependencies required.

All changes use existing AzureRM provider resources. No version changes or new providers needed.

[Testing]
Terraform validation and plan verification.

**Pre-deployment Testing:**
1. Run `terraform init` to reinitialize modules
2. Run `terraform validate` to check syntax
3. Run `terraform plan -var-file=parameters.tfvars` to preview changes
4. Verify plan shows expected resource replacements (AKS cluster will be recreated)

**Post-deployment Testing:**
1. Verify AKS cluster is accessible: `kubectl get nodes`
2. Wait for GitOps to sync (Flux will restore Istio and applications)
3. Verify Istio gateway service has LoadBalancer IP: `kubectl get svc -n istio-ingress`
4. Test external connectivity: `curl http://azr.westus2.cloudapp.azure.com`
5. Verify DNS resolution: `nslookup azr.westus2.cloudapp.azure.com`

[Implementation Order]
Sequential updates starting with module definitions, then environment configurations.

1. **Update networking module variables** (`terraform/modules/networking/variables.tf`)
   - Add new cluster subnet variables
   - Keep old variables temporarily for backward compatibility

2. **Update networking module outputs** (`terraform/modules/networking/outputs.tf`)
   - Add new cluster subnet outputs
   - Keep old outputs temporarily

3. **Update networking module resources** (`terraform/modules/networking/main.tf`)
   - Add new cluster subnet and NSG
   - Update NSG rules with correct destination_address_prefix
   - Add Istio health probe and NodePort rules

4. **Update AKS module variables** (`terraform/modules/aks/variables.tf`)
   - Add cluster_subnet_id variable

5. **Update AKS module resources** (`terraform/modules/aks/main.tf`)
   - Update subnet references to use cluster_subnet_id

6. **Update staging environment variables** (`terraform/environments/staging/variables.tf`)
   - Add cluster_subnet_prefix variable

7. **Update staging environment main** (`terraform/environments/staging/main.tf`)
   - Update module references to use new subnet names

8. **Update staging parameters** (`terraform/environments/staging/parameters.tfvars`)
   - Set cluster_subnet_prefix = "10.1.0.0/22"

9. **Remove deprecated variables from networking module** (cleanup after apply)
   - Remove system_subnet_*, workload_subnet_* variables

10. **Update dev environment** (follow same pattern as staging)
    - Update variables.tf, main.tf, parameters.tfvars

11. **Apply changes via Terraform**
    - Run `terraform plan` to verify expected changes
    - User to commit changes and trigger CI/CD pipeline

12. **Verify deployment**
    - Wait for AKS recreation
    - Wait for GitOps sync
    - Test ingress connectivity
