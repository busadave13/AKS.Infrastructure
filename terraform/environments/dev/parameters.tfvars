# Dev Environment - Variable Values
# Single-node AKS Infrastructure for Development

#--------------------------------------------------------------
# General
#--------------------------------------------------------------
identifier  = "dev"
location    = "westus"
environment = "dev"

tags = {
  Owner       = "platform-team"
  CostCenter  = "IT-1234"
  Application = "aks-microservices"
}

#--------------------------------------------------------------
# Networking
# Using same address space as staging (no peering planned)
#--------------------------------------------------------------
vnet_address_space     = ["10.1.0.0/16"]
system_subnet_prefix   = "10.1.0.0/23"
workload_subnet_prefix = "10.1.2.0/23"
private_subnet_prefix  = "10.1.4.0/24"

# Disable private endpoints for dev
enable_private_endpoints = false

#--------------------------------------------------------------
# Monitoring
#--------------------------------------------------------------
# Disable Grafana for dev to reduce costs
enable_grafana = false

# Add your Azure AD object IDs for Grafana admin access (if enabled)
grafana_admin_object_ids = []

#--------------------------------------------------------------
# AKS - Single Node Configuration
#--------------------------------------------------------------
kubernetes_version = "1.32"

# Add your Azure AD group object IDs for AKS admin access
aks_admin_group_object_ids = []

# Add your Azure AD user object IDs for AKS admin access
aks_admin_user_object_ids = ["197a7ad1-564b-4c89-9934-c50f7da5de68"]

# System Node Pool - Single node, no availability zones
system_node_count   = 1
system_node_vm_size = "Standard_B4ms"
system_node_zones   = [] # No zones for single-node cluster

# Workload Node Pool - Disabled (workloads run on system node)
enable_workload_node_pool = false

#--------------------------------------------------------------
# ACR
#--------------------------------------------------------------
acr_sku = "Basic"

#--------------------------------------------------------------
# GitOps
#--------------------------------------------------------------
enable_gitops          = true
gitops_repo_url        = "https://github.com/busadave13/K8.Infra.GitOps.git"
gitops_branch          = "staging"
public_repo            = true
git_https_user         = "git"
sync_interval_seconds  = 60
retry_interval_seconds = 60
