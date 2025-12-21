# Implementation Plan

[Overview]
Enable GitOps with Flux v2 to connect to a public GitHub repository without requiring authentication.

This implementation modifies the existing GitOps Terraform module to support unauthenticated access for public repositories. The change allows Flux to sync from public Git repositories like `https://github.com/busadave13/K8.Infra.GitOps.git` without needing a Personal Access Token (PAT). This is achieved by conditionally removing the HTTPS authentication block from the `azurerm_kubernetes_flux_configuration` resources when the repository is public.

[Types]
No new types or data structures are required for this implementation.

The existing Terraform variable types are sufficient. We add a new boolean variable `public_repo` to control authentication behavior.

[Files]
Six files require modification to support public repository access for GitOps.

**Modified Files:**
1. `terraform/modules/gitops/variables.tf` - Add `public_repo` variable, make `git_https_pat` optional
2. `terraform/modules/gitops/main.tf` - Use dynamic blocks for conditional authentication
3. `terraform/environments/dev/variables.tf` - Add `public_repo` variable
4. `terraform/environments/dev/main.tf` - Pass `public_repo` to GitOps module
5. `terraform/environments/dev/dev.tfvars` - Enable GitOps with public repo URL
6. `terraform/modules/gitops/README.md` - Document public repo support

**No new files or deleted files.**

[Functions]
No function changes required - this is Terraform HCL configuration.

The implementation uses Terraform's `dynamic` blocks to conditionally include or exclude the authentication configuration in the `git_repository` blocks based on the `public_repo` variable value.

[Classes]
No class changes required - this is Terraform HCL configuration.

[Dependencies]
No new dependencies required.

The existing `azurerm` provider (version 4.52.0) supports all required functionality. No additional Terraform providers or modules are needed.

[Testing]
Testing approach focuses on Terraform validation and plan verification.

1. **Terraform Validation**: Run `terraform validate` to ensure syntax correctness
2. **Terraform Plan**: Run `terraform plan -var-file=dev.tfvars` to verify the configuration
3. **Post-Apply Verification**: After deployment, verify Flux connectivity:
   - `kubectl get gitrepositories -n flux-system`
   - `kubectl get kustomizations -n flux-system`

[Implementation Order]
Implementation follows a bottom-up approach, modifying the module first, then the environment configuration.

1. Update `terraform/modules/gitops/variables.tf` - Add `public_repo` variable and make `git_https_pat` optional
2. Update `terraform/modules/gitops/main.tf` - Implement dynamic authentication blocks
3. Update `terraform/environments/dev/variables.tf` - Add `public_repo` variable
4. Update `terraform/environments/dev/main.tf` - Pass `public_repo` to module
5. Update `terraform/environments/dev/dev.tfvars` - Configure public repo settings
6. Update `terraform/modules/gitops/README.md` - Document public repo support
7. Validate changes with `terraform validate` and `terraform plan`
