# Bootstrap Variables

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  description = "Azure region for the Terraform state storage"
  type        = string
  default     = "westus2"
}

variable "github_repository" {
  description = "Full GitHub repository name in format 'owner/repo' (e.g., 'busadave13/AKS.Infrastructure')"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]+/[a-zA-Z0-9._-]+$", var.github_repository))
    error_message = "GitHub repository must be in format 'owner/repo'."
  }
}

variable "github_repository_name" {
  description = "Short name of the GitHub repository (e.g., 'AKS.Infrastructure')"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9._-]+$", var.github_repository_name))
    error_message = "GitHub repository name can only contain alphanumeric characters, dots, underscores, and hyphens."
  }
}

variable "enable_rbac_management" {
  description = "Enable User Access Administrator role for the service principal (required if Terraform manages RBAC)"
  type        = bool
  default     = true
}

variable "additional_federated_subjects" {
  description = "Additional federated identity subjects for custom GitHub Actions scenarios"
  type = list(object({
    name        = string
    description = string
    subject     = string
  }))
  default = []
}
