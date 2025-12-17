# Development Environment - Main Configuration
# AKS Platform Infrastructure

#--------------------------------------------------------------
# Provider Configuration
#--------------------------------------------------------------
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.85.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

#--------------------------------------------------------------
# Data Sources
#--------------------------------------------------------------
data "azurerm_client_config" "current" {}

#--------------------------------------------------------------
# Networking Module
#--------------------------------------------------------------
module "networking" {
  source = "../../modules/networking"

  resource_group_name = var.resource_group_name
  location            = var.location

  # VNet Configuration
  vnet_name          = var.vnet_name
  vnet_address_space = var.vnet_address_space

  # Subnet Configuration
  aks_subnet_name   = "snet-aks-${var.environment}-${var.location_short}"
  aks_subnet_prefix = var.aks_subnet_prefix

  pe_subnet_name   = "snet-pe-${var.environment}-${var.location_short}"
  pe_subnet_prefix = var.pe_subnet_prefix

  # NSG
  nsg_name = "nsg-platform-${var.environment}-${var.location_short}"

  tags = var.tags
}

#--------------------------------------------------------------
# Monitoring Module
#--------------------------------------------------------------
module "monitoring" {
  source = "../../modules/monitoring"

  resource_group_name = module.networking.resource_group_name
  location            = module.networking.resource_group_location
  environment         = var.environment

  # Log Analytics
  log_analytics_name = "log-platform-${var.environment}-${var.location_short}"
  log_retention_days = var.log_retention_days

  # Azure Monitor (Prometheus)
  monitor_workspace_name = "amw-platform-${var.environment}-${var.location_short}"

  # Grafana
  enable_grafana           = var.enable_grafana
  grafana_name             = "grafana-platform-${var.environment}-${var.location_short}"
  grafana_admin_object_ids = var.grafana_admin_object_ids

  # Alerting
  enable_prometheus_alerts = false
  aks_cluster_name         = ""
  alert_action_group_id    = ""

  tags = var.tags
}

#--------------------------------------------------------------
# AKS Module
#--------------------------------------------------------------
module "aks" {
  source = "../../modules/aks"

  resource_group_name = module.networking.resource_group_name
  location            = module.networking.resource_group_location

  # Cluster Configuration
  cluster_name       = "aks-platform-${var.environment}-${var.location_short}"
  dns_prefix         = "aks-platform-${var.environment}"
  kubernetes_version = var.kubernetes_version
  aks_subnet_id      = module.networking.aks_subnet_id

  # Identity
  kubelet_identity_name  = "id-aks-kubelet-${var.environment}-${var.location_short}"
  workload_identity_name = "id-aks-workload-${var.environment}-${var.location_short}"

  # System Node Pool
  system_node_count     = var.system_node_count
  system_node_min_count = var.system_node_min_count
  system_node_max_count = var.system_node_max_count
  system_node_vm_size   = var.system_node_vm_size

  # Workload Node Pool
  workload_node_count     = var.workload_node_count
  workload_node_min_count = var.workload_node_min_count
  workload_node_max_count = var.workload_node_max_count
  workload_node_vm_size   = var.workload_node_vm_size
  workload_node_spot      = var.workload_node_spot

  # Monitoring
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id

  # Azure AD Integration
  admin_group_object_ids = var.aks_admin_group_object_ids

  tags = var.tags
}

#--------------------------------------------------------------
# ACR Module
#--------------------------------------------------------------
module "acr" {
  source = "../../modules/acr"

  resource_group_name = module.networking.resource_group_name
  location            = module.networking.resource_group_location

  acr_name = var.acr_name
  sku      = var.acr_sku

  # Private Endpoint
  enable_private_endpoint    = var.enable_private_endpoints
  private_endpoint_name      = "pep-acr-${var.environment}-${var.location_short}"
  private_endpoint_subnet_id = module.networking.pe_subnet_id
  acr_private_dns_zone_id    = module.networking.acr_private_dns_zone_id

  # AKS Integration
  kubelet_identity_principal_id = module.aks.kubelet_identity_principal_id

  tags = var.tags
}

#--------------------------------------------------------------
# Key Vault Module
#--------------------------------------------------------------
module "keyvault" {
  source = "../../modules/keyvault"

  resource_group_name = module.networking.resource_group_name
  location            = module.networking.resource_group_location

  keyvault_name = "kv-platform-${var.environment}-${var.location_short}"

  # Workload Identity Access
  workload_identity_principal_id = module.aks.workload_identity_principal_id

  # GitOps PAT
  gitops_pat = var.gitops_pat

  # Private Endpoint
  enable_private_endpoint      = var.enable_private_endpoints
  private_endpoint_name        = "pep-kv-${var.environment}-${var.location_short}"
  private_endpoint_subnet_id   = module.networking.pe_subnet_id
  keyvault_private_dns_zone_id = module.networking.keyvault_private_dns_zone_id

  tags = var.tags
}

#--------------------------------------------------------------
# GitOps Module (Conditional)
#--------------------------------------------------------------
module "gitops" {
  source = "../../modules/gitops"
  count  = var.enable_gitops ? 1 : 0

  aks_cluster_id = module.aks.cluster_id
  environment    = var.environment

  # Git Repository
  gitops_repo_url = var.gitops_repo_url
  gitops_branch   = var.gitops_branch
  git_https_user  = var.git_https_user
  git_https_pat   = var.gitops_pat

  # Sync Settings
  sync_interval_seconds  = var.sync_interval_seconds
  retry_interval_seconds = var.retry_interval_seconds

  # Configuration Toggles
  enable_infrastructure_config = true
  enable_apps_config           = true
  enable_helm_releases_config  = false

  # Controller Settings
  enable_helm_controller         = true
  enable_notification_controller = true
  enable_image_automation        = false

  depends_on = [module.aks]
}
