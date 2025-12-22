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
grafana_admin_object_ids = []

#--------------------------------------------------------------
# AKS
#--------------------------------------------------------------
kubernetes_version = "1.32"

# Add your Azure AD group object IDs for AKS admin access
aks_admin_group_object_ids = []

# System Node Pool
system_node_count     = 2
system_node_min_count = 2
system_node_max_count = 3
system_node_vm_size   = "Standard_B2ms"

# Workload Node Pool
workload_node_count     = 2
workload_node_min_count = 1
workload_node_max_count = 4
workload_node_vm_size   = "Standard_B2ms"
workload_node_spot      = false

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
