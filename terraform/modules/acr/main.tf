# ACR Module
# Creates Azure Container Registry with private endpoint

#--------------------------------------------------------------
# Azure Container Registry
#--------------------------------------------------------------
resource "azurerm_container_registry" "main" {
  name                = var.acr_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = false
  tags                = var.tags

  # Geo-replication for Premium SKU only
  dynamic "georeplications" {
    for_each = var.sku == "Premium" ? var.georeplications : []
    content {
      location                = georeplications.value.location
      zone_redundancy_enabled = georeplications.value.zone_redundancy_enabled
      tags                    = var.tags
    }
  }

  # Network rules - allow Azure services
  network_rule_set {
    default_action = var.enable_private_endpoint ? "Deny" : "Allow"
  }

  # Enable content trust for Premium SKU
  trust_policy_enabled = var.sku == "Premium" ? true : false
  
  # Enable retention policy for Premium SKU
  retention_policy_in_days = var.sku == "Premium" ? var.retention_days : null
}

#--------------------------------------------------------------
# Private Endpoint for ACR
#--------------------------------------------------------------
resource "azurerm_private_endpoint" "acr" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = var.private_endpoint_name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "acr-privateserviceconnection"
    private_connection_resource_id = azurerm_container_registry.main.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "acr-dns-zone-group"
    private_dns_zone_ids = [var.acr_private_dns_zone_id]
  }
}

#--------------------------------------------------------------
# Role Assignment - AKS Kubelet Identity to ACR
#--------------------------------------------------------------
resource "azurerm_role_assignment" "kubelet_acrpull" {
  scope                = azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = var.kubelet_identity_principal_id
}
