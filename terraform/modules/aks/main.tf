# AKS Module
# Creates AKS cluster with system and workload node pools

#--------------------------------------------------------------
# User Assigned Managed Identities
#--------------------------------------------------------------

# Kubelet Identity (used by node pools to pull images from ACR)
resource "azurerm_user_assigned_identity" "kubelet" {
  name                = var.kubelet_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Workload Identity (used by pods to access Azure resources)
resource "azurerm_user_assigned_identity" "workload" {
  name                = var.workload_identity_name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

#--------------------------------------------------------------
# AKS Cluster
#--------------------------------------------------------------
resource "azurerm_kubernetes_cluster" "main" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version
  tags                = var.tags

  # Free tier for development
  sku_tier = "Free"

  # System node pool (required)
  default_node_pool {
    name                         = "system"
    vm_size                      = var.system_node_vm_size
    node_count                   = var.system_node_count
    min_count                    = var.system_node_min_count
    max_count                    = var.system_node_max_count
    auto_scaling_enabled         = true
    os_disk_type                 = "Ephemeral"
    os_disk_size_gb              = 30
    os_sku                       = "Ubuntu"
    max_pods                     = 30
    only_critical_addons_enabled = true
    zones                        = ["1", "2", "3"]
    vnet_subnet_id               = var.aks_subnet_id

    node_labels = {
      "nodepool" = "system"
    }

    upgrade_settings {
      max_surge = "10%"
    }

    tags = var.tags
  }

  # Identity configuration
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.kubelet.id]
  }

  kubelet_identity {
    client_id                 = azurerm_user_assigned_identity.kubelet.client_id
    object_id                 = azurerm_user_assigned_identity.kubelet.principal_id
    user_assigned_identity_id = azurerm_user_assigned_identity.kubelet.id
  }

  # Network configuration - Azure CNI Overlay
  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "azure"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"
    pod_cidr            = "10.244.0.0/16"
    service_cidr        = "10.245.0.0/16"
    dns_service_ip      = "10.245.0.10"
  }

  # Azure AD integration with Azure RBAC
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    admin_group_object_ids = var.admin_group_object_ids
  }

  # OIDC and Workload Identity
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  # Monitoring
  oms_agent {
    log_analytics_workspace_id      = var.log_analytics_workspace_id
    msi_auth_for_monitoring_enabled = true
  }

  # Azure Policy addon
  azure_policy_enabled = true

  # Key Vault Secrets Provider
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  # Maintenance window (weekends 02:00-06:00 UTC)
  maintenance_window {
    allowed {
      day   = "Saturday"
      hours = [2, 3, 4, 5]
    }
    allowed {
      day   = "Sunday"
      hours = [2, 3, 4, 5]
    }
  }

  # Auto-upgrade channel
  automatic_upgrade_channel = "stable"

  # Node OS auto-upgrade
  node_os_upgrade_channel = "NodeImage"

  lifecycle {
    ignore_changes = [
      # Ignore changes to node count as it's managed by autoscaler
      default_node_pool[0].node_count,
    ]
  }
}

#--------------------------------------------------------------
# Workload Node Pool (Spot Instances)
#--------------------------------------------------------------
resource "azurerm_kubernetes_cluster_node_pool" "workload" {
  name                  = "workload"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = var.workload_node_vm_size
  mode                  = "User"
  os_type               = "Linux"
  os_sku                = "Ubuntu"
  os_disk_type          = "Ephemeral"
  os_disk_size_gb       = 30
  max_pods              = 30
  zones                 = ["1", "2", "3"]
  vnet_subnet_id        = var.aks_subnet_id
  tags                  = var.tags

  # Autoscaling
  auto_scaling_enabled = true
  node_count           = var.workload_node_count
  min_count            = var.workload_node_min_count
  max_count            = var.workload_node_max_count

  # Spot instances for cost savings
  priority        = var.workload_node_spot ? "Spot" : "Regular"
  eviction_policy = var.workload_node_spot ? "Delete" : null
  spot_max_price  = var.workload_node_spot ? -1 : null

  node_labels = {
    "nodepool"                               = "workload"
    "kubernetes.azure.com/scalesetpriority" = var.workload_node_spot ? "spot" : "regular"
  }

  node_taints = var.workload_node_spot ? [
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  ] : []

  upgrade_settings {
    max_surge = "10%"
  }

  lifecycle {
    ignore_changes = [
      node_count,
    ]
  }
}

#--------------------------------------------------------------
# Federated Identity Credential for Workload Identity
#--------------------------------------------------------------
resource "azurerm_federated_identity_credential" "workload" {
  name                = "fed-${var.workload_identity_name}"
  resource_group_name = var.resource_group_name
  parent_id           = azurerm_user_assigned_identity.workload.id
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.main.oidc_issuer_url
  subject             = "system:serviceaccount:${var.workload_identity_namespace}:${var.workload_identity_service_account}"
}
