# Development Environment - Outputs

#--------------------------------------------------------------
# Resource Group
#--------------------------------------------------------------
output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.networking.resource_group_name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = module.networking.resource_group_location
}

#--------------------------------------------------------------
# Networking
#--------------------------------------------------------------
output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.networking.vnet_id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.networking.vnet_name
}

output "aks_subnet_id" {
  description = "ID of the AKS subnet"
  value       = module.networking.aks_subnet_id
}

output "pe_subnet_id" {
  description = "ID of the private endpoints subnet"
  value       = module.networking.pe_subnet_id
}

#--------------------------------------------------------------
# AKS
#--------------------------------------------------------------
output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = module.aks.cluster_id
}

output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = module.aks.cluster_name
}

output "aks_cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = module.aks.cluster_fqdn
}

output "aks_oidc_issuer_url" {
  description = "OIDC issuer URL for workload identity"
  value       = module.aks.oidc_issuer_url
}

output "kubelet_identity_client_id" {
  description = "Client ID of the kubelet managed identity"
  value       = module.aks.kubelet_identity_client_id
}

output "workload_identity_client_id" {
  description = "Client ID of the workload managed identity"
  value       = module.aks.workload_identity_client_id
}

#--------------------------------------------------------------
# ACR
#--------------------------------------------------------------
output "acr_id" {
  description = "ID of the Azure Container Registry"
  value       = module.acr.acr_id
}

output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = module.acr.acr_name
}

output "acr_login_server" {
  description = "Login server URL for the Azure Container Registry"
  value       = module.acr.acr_login_server
}

#--------------------------------------------------------------
# Key Vault
#--------------------------------------------------------------
output "keyvault_id" {
  description = "ID of the Key Vault"
  value       = module.keyvault.keyvault_id
}

output "keyvault_name" {
  description = "Name of the Key Vault"
  value       = module.keyvault.keyvault_name
}

output "keyvault_uri" {
  description = "URI of the Key Vault"
  value       = module.keyvault.keyvault_uri
}

#--------------------------------------------------------------
# Monitoring
#--------------------------------------------------------------
output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics workspace"
  value       = module.monitoring.log_analytics_workspace_id
}

output "monitor_workspace_id" {
  description = "ID of the Azure Monitor workspace"
  value       = module.monitoring.monitor_workspace_id
}

output "grafana_endpoint" {
  description = "Endpoint URL for Azure Managed Grafana"
  value       = module.monitoring.grafana_endpoint
}

#--------------------------------------------------------------
# GitOps
#--------------------------------------------------------------
output "flux_namespace" {
  description = "Namespace where Flux is installed"
  value       = var.enable_gitops ? module.gitops[0].flux_namespace : null
}

#--------------------------------------------------------------
# Useful Commands
#--------------------------------------------------------------
output "get_credentials_command" {
  description = "Command to get AKS credentials"
  value       = "az aks get-credentials --resource-group ${module.networking.resource_group_name} --name ${module.aks.cluster_name}"
}

output "acr_login_command" {
  description = "Command to login to ACR"
  value       = "az acr login --name ${module.acr.acr_name}"
}
