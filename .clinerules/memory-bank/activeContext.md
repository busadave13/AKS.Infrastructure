# Active Context: AKS.Infrastructure

## Current State
- **Project Phase**: Infrastructure Development
- **Environment**: Development (dev)
- **Region**: West US 2 (westus2)
- **CI/CD**: GitHub Actions (migrated from Azure DevOps)

## Recent Changes
- Removed 'platform' from naming convention (e.g., `rg-aks-dev-wus2` instead of `rg-aks-platform-dev-wus2`)
- Migrated CI/CD from Azure DevOps Pipelines to GitHub Actions
- Created `.github/workflows/terraform.yml` with OIDC authentication
- Removed `pipelines/azure-pipelines-terraform.yml`
- Updated documentation for GitHub Actions workflow
- Removed `gitops-config/` directory from this repository
- Updated Terraform gitops module README to clarify separate repository pattern

## Active Work Items
None currently active.

## Pending Tasks
1. Create the separate AKS.GitOps repository
2. Set up GitHub OIDC federation with Azure AD
3. Configure GitHub repository secrets
4. Deploy infrastructure using Terraform
5. Validate GitOps sync from separate repository

## Key Decisions Made
| Date | Decision | Rationale |
|------|----------|-----------|
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
