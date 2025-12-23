# Staging Environment - Variable Values
# AKS Infrastructure

#--------------------------------------------------------------
# General
#--------------------------------------------------------------
identifier  = "xpci"
location    = "westus2"
environment = "staging"

tags = {
  Owner       = "platform-team"
  CostCenter  = "IT-1234"
  Application = "aks-microservices"
}

#--------------------------------------------------------------
# Networking
# Using 10.1.0.0/16 to avoid conflicts with dev (10.0.0.0/16)
#--------------------------------------------------------------
vnet_address_space     = ["10.1.0.0/16"]
system_subnet_prefix   = "10.1.0.0/23"
workload_subnet_prefix = "10.1.2.0/23"
private_subnet_prefix  = "10.1.4.0/24"

# Disable private endpoints for staging (enable for more production-like setup)
enable_private_endpoints = false

#--------------------------------------------------------------
# Monitoring
#--------------------------------------------------------------
enable_grafana = true

# Add your Azure AD object IDs for Grafana admin access
grafana_admin_object_ids = ["197a7ad1-564b-4c89-9934-c50f7da5de68"]

#--------------------------------------------------------------
# AKS
#--------------------------------------------------------------
kubernetes_version = "1.32"

# Add your Azure AD group object IDs for AKS admin access
aks_admin_group_object_ids = []

# Add your Azure AD user object IDs for AKS admin access
aks_admin_user_object_ids = ["197a7ad1-564b-4c89-9934-c50f7da5de68"]

# System Node Pool - 1 node, no availability zones
system_node_count    = 1
system_node_vm_size  = "Standard_D4s_v5"
system_node_zones    = [] # No zones for multi-node cluster without zone redundancy
system_node_max_pods = 50

# Workload Node Pool - 1 node, no availability zones
enable_workload_node_pool = true
workload_node_count       = 1
workload_node_vm_size     = "Standard_B4ms"
workload_node_zones       = [] # No zones for multi-node cluster without zone redundancy
workload_node_spot        = false
workload_node_max_pods    = 30

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
