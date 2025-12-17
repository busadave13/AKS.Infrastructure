# GitOps Module - Outputs

#--------------------------------------------------------------
# Flux Extension
#--------------------------------------------------------------
output "flux_extension_id" {
  description = "ID of the Flux extension"
  value       = azurerm_kubernetes_cluster_extension.flux.id
}

output "flux_extension_name" {
  description = "Name of the Flux extension"
  value       = azurerm_kubernetes_cluster_extension.flux.name
}

output "flux_namespace" {
  description = "Namespace where Flux is installed"
  value       = "flux-system"
}

#--------------------------------------------------------------
# Flux Configurations
#--------------------------------------------------------------
output "infrastructure_config_id" {
  description = "ID of the infrastructure Flux configuration"
  value       = var.enable_infrastructure_config ? azurerm_kubernetes_flux_configuration.infrastructure[0].id : null
}

output "apps_config_id" {
  description = "ID of the apps Flux configuration"
  value       = var.enable_apps_config ? azurerm_kubernetes_flux_configuration.apps[0].id : null
}

output "helm_releases_config_id" {
  description = "ID of the Helm releases Flux configuration"
  value       = var.enable_helm_releases_config ? azurerm_kubernetes_flux_configuration.helm_releases[0].id : null
}
