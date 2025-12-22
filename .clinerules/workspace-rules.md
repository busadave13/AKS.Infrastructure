# Workspace Rules

## Purpose
This document defines workspace-specific rules and constraints for the AKS.Infra repository.

---

## Critical Operations - User Consent Required

### Terraform Operations
**NEVER run `terraform apply` from the local machine without explicit user consent.**

- Terraform apply operations should be performed via GitHub Actions CI/CD pipeline
- If the user requests infrastructure changes, prepare the Terraform code changes and inform them to:
  1. Commit and push the changes
  2. Run the appropriate GitHub Actions workflow
- Only run `terraform plan` locally for validation purposes
- If absolutely necessary to run `terraform apply` locally, you MUST ask for explicit user approval first

### Git Operations
**NEVER commit or push changes without explicit user consent.**

- After making file changes, inform the user what files were modified
- Let the user review and commit/push changes themselves
- Do not use `git commit` or `git push` commands automatically
- Do not use GitHub MCP tools to create commits or push changes without asking first

---

## Allowed Local Operations

The following operations ARE safe to run locally without explicit consent:

### Terraform (Read-Only)
- `terraform init` - Initialize working directory
- `terraform validate` - Validate configuration
- `terraform plan` - Preview changes (read-only)
- `terraform fmt` - Format code
- `terraform state list` - List state resources

### Git (Read-Only)
- `git status` - Check repository status
- `git diff` - View changes
- `git log` - View commit history
- `git branch` - List branches

### Azure CLI (Read-Only)
- `az account show` - Show current account
- `az aks list` - List AKS clusters
- `az aks get-credentials` - Get cluster credentials
- Any `az ... show` or `az ... list` commands

### Kubernetes (Read-Only)
- `kubectl get` - Get resources
- `kubectl describe` - Describe resources
- `kubectl logs` - View logs
- MCP tools for reading Kubernetes state

---

## Workflow Guidelines

1. **For infrastructure changes:**
   - Make Terraform code changes locally
   - Validate with `terraform plan`
   - Inform user to commit/push and trigger GitHub Actions

2. **For GitOps/Kubernetes debugging:**
   - Use kubectl and MCP tools freely for read operations
   - For write operations (apply, delete, patch), ask for user consent

3. **For code changes:**
   - Make file changes as needed
   - Summarize changes made
   - Let user handle git commit/push
