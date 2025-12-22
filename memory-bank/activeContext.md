# Active Context: AKS.Infrastructure

## Current State
- **Project Phase**: Infrastructure Development
- **Environment**: Staging
- **Region**: West US 2 (westus2)
- **Identifier**: xpci
- **CI/CD**: GitHub Actions (migrated from Azure DevOps)

## Recent Changes
- Refactored staging environment to use common module for CAF-compliant naming
- Added `identifier` variable (xpci) for resource naming
- Created `provider.tf` to separate provider configuration from main.tf
- Updated common module output name from `region_abbrev` to `region_abbreviation`
- Added monitoring module outputs.tf
- Resource naming now follows pattern: `{resource-type}-{identifier}-{environment}-{region-abbreviation}`
- Removed hardcoded resource names (vnet_name, acr_name) - now computed from common module
- Removed 'platform' from naming convention (e.g., `rg-aks-dev-wus2` instead of `rg-aks-platform-dev-wus2`)
- Migrated CI/CD from Azure DevOps Pipelines to GitHub Actions
- Created `.github/workflows/terraform.yml` with OIDC authentication
- Removed `pipelines/azure-pipelines-terraform.yml`
- Updated documentation for GitHub Actions workflow
- Removed `gitops-config/` directory from this repository
- Updated Terraform gitops module README to clarify separate repository pattern

## Active Work Items
Staging environment terraform refactoring complete.

## Pending Tasks
1. Apply same refactoring pattern to other environments (dev, prod)
2. Create the separate AKS.GitOps repository
3. Set up GitHub OIDC federation with Azure AD
4. Configure GitHub repository secrets
5. Deploy infrastructure using Terraform
6. Validate GitOps sync from separate repository

## Key Decisions Made
| Date | Decision | Rationale |
|------|----------|-----------|
| 2024-12 | Common module for naming | Consistent CAF-compliant naming across all resources |
| 2024-12 | Identifier-based naming | `xpci` identifier provides project-specific resource names |
| 2024-12 | Provider in separate file | Better separation of concerns, cleaner main.tf |
| 2024-12 | GitHub Actions for CI/CD | Simpler OIDC setup, native GitHub integration, no additional tooling |
| 2024-12 | Separate GitOps repository | Independent versioning, access control, release management |
| 2024-12 | Use Spot instances for workloads | 60-90% cost savings on non-critical dev workloads |
| 2024-12 | Public AKS cluster | Simplifies development access; secured via Azure RBAC |

## Current Blockers
None identified.

## Notes
- GitOps configuration should be managed in AKS.GitOps repository
- Flux v2 is configured to sync from the separate repository
- The `gitops_repo_url` variable in Terraform should point to AKS.GitOps
- GitHub Actions uses OIDC for passwordless Azure authentication
