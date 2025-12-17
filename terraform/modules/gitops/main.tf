# GitOps Module
# Creates Flux v2 extension and configuration for AKS

#--------------------------------------------------------------
# Flux Extension
#--------------------------------------------------------------
resource "azurerm_kubernetes_cluster_extension" "flux" {
  name           = "flux"
  cluster_id     = var.aks_cluster_id
  extension_type = "microsoft.flux"

  configuration_settings = {
    # Core controllers (required)
    "source-controller.enabled"       = "true"
    "kustomize-controller.enabled"    = "true"

    # Helm support (recommended)
    "helm-controller.enabled" = tostring(var.enable_helm_controller)

    # Notifications for alerts (recommended)
    "notification-controller.enabled" = tostring(var.enable_notification_controller)

    # Image automation (optional)
    "image-automation-controller.enabled" = tostring(var.enable_image_automation)
    "image-reflector-controller.enabled"  = tostring(var.enable_image_automation)
  }
}

#--------------------------------------------------------------
# Flux Configuration - Infrastructure
#--------------------------------------------------------------
resource "azurerm_kubernetes_flux_configuration" "infrastructure" {
  count = var.enable_infrastructure_config ? 1 : 0

  name       = "flux-infrastructure"
  cluster_id = var.aks_cluster_id
  namespace  = "flux-system"
  scope      = "cluster"

  git_repository {
    url                      = var.gitops_repo_url
    reference_type           = "branch"
    reference_value          = var.gitops_branch
    https_user               = var.git_https_user
    https_key_base64         = base64encode(var.git_https_pat)
    sync_interval_in_seconds = var.sync_interval_seconds
    timeout_in_seconds       = 600
  }

  kustomizations {
    name                       = "infrastructure"
    path                       = "./infrastructure/overlays/${var.environment}"
    sync_interval_in_seconds   = var.sync_interval_seconds * 2
    retry_interval_in_seconds  = var.retry_interval_seconds
    recreating_enabled         = false
  }

  depends_on = [azurerm_kubernetes_cluster_extension.flux]
}

#--------------------------------------------------------------
# Flux Configuration - Applications
#--------------------------------------------------------------
resource "azurerm_kubernetes_flux_configuration" "apps" {
  count = var.enable_apps_config ? 1 : 0

  name       = "flux-apps"
  cluster_id = var.aks_cluster_id
  namespace  = "flux-system"
  scope      = "cluster"

  git_repository {
    url                      = var.gitops_repo_url
    reference_type           = "branch"
    reference_value          = var.gitops_branch
    https_user               = var.git_https_user
    https_key_base64         = base64encode(var.git_https_pat)
    sync_interval_in_seconds = var.sync_interval_seconds
    timeout_in_seconds       = 600
  }

  kustomizations {
    name                       = "apps"
    path                       = "./apps/overlays/${var.environment}"
    sync_interval_in_seconds   = var.sync_interval_seconds
    retry_interval_in_seconds  = var.retry_interval_seconds
    depends_on                 = var.enable_infrastructure_config ? ["infrastructure"] : []
  }

  depends_on = [
    azurerm_kubernetes_cluster_extension.flux,
    azurerm_kubernetes_flux_configuration.infrastructure
  ]
}

#--------------------------------------------------------------
# Flux Configuration - Helm Releases
#--------------------------------------------------------------
resource "azurerm_kubernetes_flux_configuration" "helm_releases" {
  count = var.enable_helm_releases_config ? 1 : 0

  name       = "flux-helm-releases"
  cluster_id = var.aks_cluster_id
  namespace  = "flux-system"
  scope      = "cluster"

  git_repository {
    url                      = var.gitops_repo_url
    reference_type           = "branch"
    reference_value          = var.gitops_branch
    https_user               = var.git_https_user
    https_key_base64         = base64encode(var.git_https_pat)
    sync_interval_in_seconds = 300
    timeout_in_seconds       = 600
  }

  kustomizations {
    name                       = "helm-sources"
    path                       = "./helm-releases/base/sources"
    sync_interval_in_seconds   = 300
    retry_interval_in_seconds  = 120
  }

  kustomizations {
    name                       = "helm-releases"
    path                       = "./helm-releases/overlays/${var.environment}"
    sync_interval_in_seconds   = 300
    retry_interval_in_seconds  = 120
    depends_on                 = ["helm-sources"]
  }

  depends_on = [azurerm_kubernetes_cluster_extension.flux]
}
