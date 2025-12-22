# Common Module Variables

variable "identifier" {
  description = "Project or workload identifier used in resource naming"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]+$", var.identifier))
    error_message = "Identifier must contain only lowercase letters and numbers."
  }
}

variable "environment" {
  description = "Environment name (dev, test, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, staging, prod."
  }
}

variable "location" {
  description = "Azure region for resources"
  type        = string
}

variable "additional_tags" {
  description = "Additional tags to merge with standard tags"
  type        = map(string)
  default     = {}
}
