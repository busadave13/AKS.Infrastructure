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

# Control Plane Identity (used by AKS control plane)
resource "azurerm_user_assigned_identity" "control_plane" {
  name                = replace(var.kubelet_identity_name, "kubelet", "cp")
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Grant Control Plane identity "Managed Identity Operator" on Kubelet identity
resource "azurerm_role_assignment" "control_plane_mi_operator" {
  scope                = azurerm_user_assigned_identity.kubelet.id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.control_plane.principal_id
}

# Grant Control Plane identity "Network Contributor" on the resource group
# This allows AKS to manage load balancer frontend configurations for ingress public IPs
resource "azurerm_role_assignment" "control_plane_network_contributor" {
  count = var.ingress_resource_group_id != null ? 1 : 0

  scope                = var.ingress_resource_group_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.control_plane.principal_id
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
  node_resource_group = var.node_resource_group
  tags                = var.tags

  # Free tier for development
  sku_tier = "Free"

  # System node pool (required)
  default_node_pool {
    name                 = "system"
    vm_size              = var.system_node_vm_size
    node_count           = var.system_node_count
    auto_scaling_enabled = false
    os_disk_type         = var.system_node_os_disk_type
    os_disk_size_gb      = 30
    os_sku               = "Ubuntu"
    max_pods             = var.system_node_max_pods
    vnet_subnet_id       = var.system_subnet_id

    # Only enable critical addons restriction when workload pool exists
    # When no workload pool, workloads must run on system nodes
    only_critical_addons_enabled = var.enable_workload_node_pool

    # Availability zones - use null when empty list (for single-node clusters)
    zones = length(var.system_node_zones) > 0 ? var.system_node_zones : null

    node_labels = {
      "nodepool" = "system"
    }

    upgrade_settings {
      max_surge = "10%"
    }

    tags = var.tags
  }

  # Identity configuration - uses control plane identity
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.control_plane.id]
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

    # Use static public IP for egress
    load_balancer_profile {
      outbound_ip_address_ids = [var.egress_public_ip_id]
    }
  }

  # Azure AD integration with Azure RBAC
  azure_active_directory_role_based_access_control {
    azure_rbac_enabled     = true
    admin_group_object_ids = var.admin_group_object_ids
  }

  # OIDC and Workload Identity
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

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

  depends_on = [azurerm_role_assignment.control_plane_mi_operator]
}

#--------------------------------------------------------------
# Workload Node Pool (Optional - Spot Instances)
#--------------------------------------------------------------
resource "azurerm_kubernetes_cluster_node_pool" "workload" {
  count = var.enable_workload_node_pool ? 1 : 0

  name                        = "workload"
  kubernetes_cluster_id       = azurerm_kubernetes_cluster.main.id
  vm_size                     = var.workload_node_vm_size
  mode                        = "User"
  os_type                     = "Linux"
  os_sku                      = "Ubuntu"
  os_disk_type                = var.workload_node_os_disk_type
  os_disk_size_gb             = 30
  max_pods                    = var.workload_node_max_pods
  vnet_subnet_id              = var.workload_subnet_id
  temporary_name_for_rotation = "workloadtmp"
  tags                        = var.tags

  # Fixed node count (no autoscaling)
  auto_scaling_enabled = false
  node_count           = var.workload_node_count

  # Availability zones - use null when empty list
  zones = length(var.workload_node_zones) > 0 ? var.workload_node_zones : null

  # Spot instances for cost savings
  priority        = var.workload_node_spot ? "Spot" : "Regular"
  eviction_policy = var.workload_node_spot ? "Delete" : null
  spot_max_price  = var.workload_node_spot ? -1 : null

  node_labels = {
    "nodepool" = "workload"
  }

  node_taints = var.workload_node_spot ? [
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  ] : []

  # Upgrade settings - not allowed for spot node pools
  dynamic "upgrade_settings" {
    for_each = var.workload_node_spot ? [] : [1]
    content {
      max_surge = "10%"
    }
  }
}

#--------------------------------------------------------------
# Azure RBAC Role Assignments for Cluster Admin Access
#--------------------------------------------------------------
resource "azurerm_role_assignment" "cluster_admin_users" {
  for_each = toset(var.admin_user_object_ids)

  scope                = azurerm_kubernetes_cluster.main.id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  principal_id         = each.value
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
