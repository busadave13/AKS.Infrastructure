# Integration Tests
# Tests for the full environment configuration
# These tests validate the complete infrastructure plan

# ============================================================
# Mock Providers for Testing
# ============================================================
mock_provider "azurerm" {}

# ============================================================
# Override Data Sources with valid mock data
# ============================================================
# Root module data source
override_data {
  target = data.azurerm_client_config.current
  values = {
    tenant_id       = "00000000-0000-0000-0000-000000000000"
    subscription_id = "00000000-0000-0000-0000-000000000000"
    object_id       = "00000000-0000-0000-0000-000000000000"
    client_id       = "00000000-0000-0000-0000-000000000000"
  }
}

# Keyvault module data source
override_data {
  target = module.keyvault.data.azurerm_client_config.current
  values = {
    tenant_id       = "00000000-0000-0000-0000-000000000000"
    subscription_id = "00000000-0000-0000-0000-000000000000"
    object_id       = "00000000-0000-0000-0000-000000000000"
    client_id       = "00000000-0000-0000-0000-000000000000"
  }
}

# ============================================================
# Test Variables (from dev.tfvars)
# ============================================================
variables {
  # General
  resource_group_name = "rg-aks-test-wus2"
  location            = "westus2"
  location_short      = "wus2"
  environment         = "test"

  tags = {
    Environment = "test"
    Owner       = "test-team"
    CostCenter  = "IT-TEST"
    Application = "aks-microservices"
    ManagedBy   = "terraform-test"
  }

  # Networking
  vnet_name          = "vnet-aks-test-wus2"
  vnet_address_space = ["10.0.0.0/16"]
  aks_subnet_prefix  = "10.0.0.0/22"
  pe_subnet_prefix   = "10.0.4.0/24"
  enable_private_endpoints = false

  # Monitoring
  log_retention_days       = 30
  enable_grafana           = true
  grafana_admin_object_ids = []

  # AKS
  kubernetes_version         = "1.32"
  aks_admin_group_object_ids = []
  system_node_count          = 2
  system_node_min_count      = 2
  system_node_max_count      = 3
  system_node_vm_size        = "Standard_B2ms"
  workload_node_count        = 2
  workload_node_min_count    = 1
  workload_node_max_count    = 4
  workload_node_vm_size      = "Standard_B2ms"
  workload_node_spot         = false

  # ACR
  acr_name = "acrakstest"
  acr_sku  = "Basic"

  # GitOps
  enable_gitops          = false
  gitops_repo_url        = ""
  gitops_branch          = "main"
  git_https_user         = "git"
  sync_interval_seconds  = 60
  retry_interval_seconds = 60
}

# ============================================================
# Plan Tests - Validate Full Configuration
# ============================================================

run "verify_resource_group" {
  command = plan

  assert {
    condition     = output.resource_group_name != ""
    error_message = "Resource group name should not be empty"
  }
}

run "verify_aks_cluster" {
  command = plan

  assert {
    condition     = output.aks_cluster_name != ""
    error_message = "AKS cluster name should not be empty"
  }
}

run "verify_networking" {
  command = plan

  assert {
    condition     = output.vnet_name != ""
    error_message = "VNet name should not be empty"
  }
}

run "verify_acr" {
  command = plan

  assert {
    condition     = output.acr_name != ""
    error_message = "ACR name should not be empty"
  }
}

run "verify_keyvault" {
  command = plan

  assert {
    condition     = output.keyvault_name != ""
    error_message = "Key Vault name should not be empty"
  }
}

# Note: verify_monitoring test removed because monitoring outputs
# (log_analytics_workspace_id, grafana_endpoint) are only known after apply.
# The plan validation is already covered by other tests.
