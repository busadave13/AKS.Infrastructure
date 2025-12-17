# Dev Environment - Main Configuration
# AKS Dev Cluster with GitOps (Flux) for microservices

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.14"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

# Configure the Azure Provider
# 
# Authentication is handled via OIDC/Workload Identity in GitHub Actions.
# The following environment variables are set by the workflow:
# - ARM_CLIENT_ID: Azure AD Application (Client) ID
# - ARM_TENANT_ID: Azure AD Tenant ID  
# - ARM_SUBSCRIPTION_ID: Azure Subscription ID
# - ARM_USE_OIDC: Set to "true" to enable OIDC authentication
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

provider "azuread" {
  # Uses the same OIDC authentication as azurerm provider
}

# Local variables for naming convention
locals {
  # Naming convention: {resource-type}-{project}-{environment}-{region}
  resource_group_name          = "rg-${var.project_name}-${var.environment}-${var.location}"
  vnet_name                    = "vnet-${var.project_name}-${var.environment}"
  aks_cluster_name             = "aks-${var.project_name}-${var.environment}-${var.location}"
  log_analytics_workspace_name = "log-${var.project_name}-${var.environment}-${var.location}"

  # Monitoring resource names
  monitor_workspace_name        = "mon-${var.project_name}-${var.environment}-${var.location}"
  data_collection_endpoint_name = "dce-${var.project_name}-${var.environment}-${var.location}"
  data_collection_rule_name     = "dcr-${var.project_name}-${var.environment}-${var.location}"
  grafana_name                  = "graf-${var.project_name}-${var.environment}"

  # Common tags
  common_tags = merge(var.tags, {
    Environment = var.environment
    ManagedBy   = "terraform"
    Project     = var.project_name
  })
}

# Resource Group
resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name
  location = var.location

  tags = local.common_tags
}

# Networking Module
module "networking" {
  source = "../../modules/networking"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  environment         = var.environment

  vnet_name          = local.vnet_name
  vnet_address_space = ["10.224.0.0/16"]

  aks_subnet_name           = "snet-aks"
  aks_subnet_address_prefix = "10.224.0.0/20"

  tags = local.common_tags
}

# Azure Container Registry Module
module "acr" {
  source = "../../modules/acr"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  acr_name      = var.acr_name
  sku           = "Basic"
  admin_enabled = false

  tags = local.common_tags
}

# Monitoring Module (Log Analytics, Prometheus, Grafana)
module "monitoring" {
  source = "../../modules/monitoring"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  # Log Analytics
  log_analytics_workspace_name = local.log_analytics_workspace_name
  retention_in_days            = 30

  # Prometheus
  prometheus_enabled                       = var.prometheus_enabled
  monitor_workspace_name                   = local.monitor_workspace_name
  data_collection_endpoint_name            = local.data_collection_endpoint_name
  data_collection_rule_name                = local.data_collection_rule_name
  prometheus_public_network_access_enabled = var.prometheus_public_network_access_enabled

  # Grafana
  grafana_enabled                       = var.grafana_enabled
  grafana_name                          = local.grafana_name
  grafana_sku                           = var.grafana_sku
  grafana_zone_redundancy_enabled       = var.grafana_zone_redundancy_enabled
  grafana_public_network_access_enabled = var.grafana_public_network_access_enabled

  tags = local.common_tags
}

# AKS Cluster Module
module "aks" {
  source = "../../modules/aks"

  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  cluster_name       = local.aks_cluster_name
  dns_prefix         = "${var.project_name}-${var.environment}"
  kubernetes_version = var.kubernetes_version
  sku_tier           = "Free"

  # Network Configuration
  vnet_subnet_id      = module.networking.aks_subnet_id
  network_plugin      = "azure"
  network_plugin_mode = "overlay"
  network_policy      = "azure"
  pod_cidr            = "10.244.0.0/16"
  service_cidr        = "10.0.0.0/16"
  dns_service_ip      = "10.0.0.10"

  # System Node Pool - Minimal for dev
  system_node_pool_name            = "system"
  system_node_pool_vm_size         = "Standard_B2ms"
  system_node_pool_node_count      = 1
  system_node_pool_os_disk_size_gb = 30

  # User Node Pool - Spot instances for cost savings
  user_node_pool_name            = "user"
  user_node_pool_vm_size         = "Standard_B2ms"
  user_node_pool_min_count       = 1
  user_node_pool_max_count       = 2
  user_node_pool_os_disk_size_gb = 30
  user_node_pool_spot_enabled    = true

  # Azure AD Integration
  azure_rbac_enabled     = true
  admin_group_object_ids = var.admin_group_object_ids

  # Monitoring - Container Insights
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id

  # Prometheus Monitoring
  prometheus_enabled       = var.prometheus_enabled
  data_collection_rule_id  = module.monitoring.data_collection_rule_id

  # ACR Integration
  acr_id = module.acr.acr_id

  # GitOps (Flux)
  gitops_enabled = true

  tags = local.common_tags

  depends_on = [
    module.networking,
    module.acr,
    module.monitoring
  ]
}
