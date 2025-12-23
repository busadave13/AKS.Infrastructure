# Staging Environment - Main Configuration
# AKS Infrastructure

#--------------------------------------------------------------
# Data Sources
#--------------------------------------------------------------
data "azurerm_client_config" "current" {}

#--------------------------------------------------------------
# Common Module
#--------------------------------------------------------------
module "common" {
  source = "../../modules/common"

  identifier      = var.identifier
  environment     = var.environment
  location        = var.location
  additional_tags = var.tags
}

#--------------------------------------------------------------
# Networking Module
#--------------------------------------------------------------
module "networking" {
  source = "../../modules/networking"

  resource_group_name = "rg-${module.common.naming_prefix}"
  location            = module.common.location

  # VNet Configuration
  vnet_name          = "vnet-${module.common.naming_prefix}"
  vnet_address_space = var.vnet_address_space

  # Cluster Subnet Configuration (unified subnet for all AKS node pools)
  cluster_subnet_prefix = var.cluster_subnet_prefix
  cluster_nsg_name      = "nsg-cluster-${module.common.naming_prefix}"

  # Private Subnet Configuration
  private_subnet_prefix = var.private_subnet_prefix
  private_nsg_name      = "nsg-private-${module.common.naming_prefix}"

  # Public IP for Egress
  egress_public_ip_name = "pip-egress-${module.common.naming_prefix}"

  # Public IP for Ingress (with DNS label)
  ingress_public_ip_name = "pip-ingress-${module.common.naming_prefix}"
  ingress_dns_label      = "davhar"

  # Availability Zones - use same zones as AKS system nodes
  zones = var.system_node_zones

  tags = module.common.tags
}

#--------------------------------------------------------------
# Monitoring Module
#--------------------------------------------------------------
module "monitoring" {
  source = "../../modules/monitoring"

  resource_group_name = module.networking.resource_group_name
  location            = module.networking.resource_group_location
  environment         = module.common.environment

  # Azure Monitor (Prometheus)
  monitor_workspace_name = "amw-${module.common.naming_prefix}"

  # Grafana
  enable_grafana           = var.enable_grafana
  grafana_name             = "graf-${module.common.naming_prefix}"
  grafana_admin_object_ids = var.grafana_admin_object_ids

  # Alerting
  enable_prometheus_alerts = false
  aks_cluster_name         = ""
  alert_action_group_id    = ""

  tags = module.common.tags
}

#--------------------------------------------------------------
# AKS Module
#--------------------------------------------------------------
module "aks" {
  source = "../../modules/aks"

  resource_group_name = module.networking.resource_group_name
  location            = module.networking.resource_group_location

  # Cluster Configuration
  cluster_name        = "aks-${module.common.naming_prefix}"
  node_resource_group = "rg-aks-nodes-${module.common.naming_prefix}"
  dns_prefix          = "aks-${module.common.identifier}-${module.common.environment}"
  kubernetes_version  = var.kubernetes_version
  cluster_subnet_id   = module.networking.cluster_subnet_id

  # Identity
  kubelet_identity_name  = "id-kubelet-${module.common.naming_prefix}"
  workload_identity_name = "id-workload-${module.common.naming_prefix}"

  # System Node Pool
  system_node_count        = var.system_node_count
  system_node_vm_size      = var.system_node_vm_size
  system_node_zones        = var.system_node_zones
  system_node_max_pods     = var.system_node_max_pods
  system_node_os_disk_type = var.system_node_os_disk_type

  # Compute Node Pool
  compute_node_count        = var.compute_node_count
  compute_node_vm_size      = var.compute_node_vm_size
  compute_node_zones        = var.compute_node_zones
  compute_node_spot         = var.compute_node_spot
  compute_node_max_pods     = var.compute_node_max_pods
  compute_node_os_disk_type = var.compute_node_os_disk_type

  # Egress
  egress_public_ip_id = module.networking.egress_public_ip_id

  # Ingress - grant Network Contributor on resource group for load balancer management
  ingress_resource_group_id = module.networking.resource_group_id

  # Azure AD Integration
  admin_group_object_ids = var.aks_admin_group_object_ids
  admin_user_object_ids  = var.aks_admin_user_object_ids

  tags = module.common.tags
}

#--------------------------------------------------------------
# ACR Module
#--------------------------------------------------------------
module "acr" {
  source = "../../modules/acr"

  resource_group_name = module.networking.resource_group_name
  location            = module.networking.resource_group_location

  acr_name = "cr${module.common.identifier}${module.common.environment}${module.common.region_abbreviation}"
  sku      = var.acr_sku

  # Private Endpoint
  enable_private_endpoint    = var.enable_private_endpoints
  private_endpoint_name      = "pep-acr-${module.common.naming_prefix}"
  private_endpoint_subnet_id = module.networking.private_subnet_id
  acr_private_dns_zone_id    = module.networking.acr_private_dns_zone_id

  # AKS Integration
  kubelet_identity_principal_id = module.aks.kubelet_identity_principal_id

  tags = module.common.tags
}

#--------------------------------------------------------------
# Key Vault Module
#--------------------------------------------------------------
module "keyvault" {
  source = "../../modules/keyvault"

  resource_group_name = module.networking.resource_group_name
  location            = module.networking.resource_group_location

  keyvault_name = "kv-${module.common.naming_prefix}"

  # Workload Identity Access (enabled after AKS is created)
  enable_workload_identity_access = true
  workload_identity_principal_id  = module.aks.workload_identity_principal_id

  # GitOps PAT
  gitops_pat = var.gitops_pat

  # Private Endpoint
  enable_private_endpoint      = var.enable_private_endpoints
  private_endpoint_name        = "pep-kv-${module.common.naming_prefix}"
  private_endpoint_subnet_id   = module.networking.private_subnet_id
  keyvault_private_dns_zone_id = module.networking.keyvault_private_dns_zone_id

  tags = module.common.tags
}

#--------------------------------------------------------------
# GitOps Module (Conditional)
#--------------------------------------------------------------
module "gitops" {
  source = "../../modules/gitops"
  count  = var.enable_gitops ? 1 : 0

  aks_cluster_id = module.aks.cluster_id
  environment    = module.common.environment

  # Git Repository
  gitops_repo_url = var.gitops_repo_url
  gitops_branch   = var.gitops_branch
  public_repo     = var.public_repo
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
