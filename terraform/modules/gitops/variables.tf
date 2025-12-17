# GitOps Module - Variables

variable "aks_cluster_id" {
  description = "ID of the AKS cluster"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

#--------------------------------------------------------------
# Flux Extension Settings
#--------------------------------------------------------------
variable "enable_helm_controller" {
  description = "Enable Helm controller for Helm releases"
  type        = bool
  default     = true
}

variable "enable_notification_controller" {
  description = "Enable notification controller for alerts"
  type        = bool
  default     = true
}

variable "enable_image_automation" {
  description = "Enable image automation controllers"
  type        = bool
  default     = false
}

#--------------------------------------------------------------
# Git Repository Settings
#--------------------------------------------------------------
variable "gitops_repo_url" {
  description = "URL of the GitOps repository"
  type        = string
}

variable "gitops_branch" {
  description = "Branch to sync from"
  type        = string
  default     = "main"
}

variable "git_https_user" {
  description = "HTTPS username for Git authentication"
  type        = string
  default     = "git"
}

variable "git_https_pat" {
  description = "Personal Access Token for Git authentication"
  type        = string
  sensitive   = true
}

#--------------------------------------------------------------
# Sync Settings
#--------------------------------------------------------------
variable "sync_interval_seconds" {
  description = "Interval in seconds for syncing with Git repository"
  type        = number
  default     = 60
}

variable "retry_interval_seconds" {
  description = "Interval in seconds for retrying failed syncs"
  type        = number
  default     = 60
}

#--------------------------------------------------------------
# Configuration Toggles
#--------------------------------------------------------------
variable "enable_infrastructure_config" {
  description = "Enable Flux configuration for infrastructure"
  type        = bool
  default     = true
}

variable "enable_apps_config" {
  description = "Enable Flux configuration for applications"
  type        = bool
  default     = true
}

variable "enable_helm_releases_config" {
  description = "Enable Flux configuration for Helm releases"
  type        = bool
  default     = false
}
