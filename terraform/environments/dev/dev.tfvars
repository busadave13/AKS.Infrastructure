# Development Environment - Variable Values
# AKS Platform Infrastructure

#--------------------------------------------------------------
# General
#--------------------------------------------------------------
resource_group_name = "rg-aks-platform-dev-wus3"
location            = "westus3"
location_short      = "wus3"
environment         = "dev"

tags = {
  Environment = "dev"
  Owner       = "platform-team"
  CostCenter  = "IT-1234"
  Application = "aks-platform"
  ManagedBy   = "terraform"
}

#--------------------------------------------------------------
# Networking
#--------------------------------------------------------------
vnet_name          = "vnet-platform-dev-wus3"
vnet_address_space = ["10.0.0.0/16"]
aks_subnet_prefix  = "10.0.0.0/22"
pe_subnet_prefix   = "10.0.4.0/24"

# Disable private endpoints for dev (simplifies access)
enable_private_endpoints = false

#--------------------------------------------------------------
# Monitoring
#--------------------------------------------------------------
log_retention_days = 30
enable_grafana     = true

# Add your Azure AD object IDs for Grafana admin access
grafana_admin_object_ids = []

#--------------------------------------------------------------
# AKS
#--------------------------------------------------------------
kubernetes_version = "1.30"

# Add your Azure AD group object IDs for AKS admin access
aks_admin_group_object_ids = []

# System Node Pool
system_node_count     = 2
system_node_min_count = 2
system_node_max_count = 3
system_node_vm_size   = "Standard_B2ms"

# Workload Node Pool (Spot instances for cost savings)
workload_node_count     = 2
workload_node_min_count = 1
workload_node_max_count = 4
workload_node_vm_size   = "Standard_B2ms"
workload_node_spot      = true

#--------------------------------------------------------------
# ACR
#--------------------------------------------------------------
acr_name = "acrplatformdevwus3"
acr_sku  = "Basic"

#--------------------------------------------------------------
# GitOps (Disabled by default)
#--------------------------------------------------------------
enable_gitops          = false
gitops_repo_url        = ""
gitops_branch          = "main"
git_https_user         = "git"
sync_interval_seconds  = 60
retry_interval_seconds = 60
