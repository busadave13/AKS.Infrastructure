# AKS Module - Outputs

#--------------------------------------------------------------
# Cluster Outputs
#--------------------------------------------------------------
output "cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.id
}

output "cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "cluster_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.fqdn
}

output "kube_config_raw" {
  description = "Raw Kubernetes config for the cluster"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "kube_admin_config_raw" {
  description = "Raw Kubernetes admin config for the cluster"
  value       = azurerm_kubernetes_cluster.main.kube_admin_config_raw
  sensitive   = true
}

output "host" {
  description = "Kubernetes API server host"
  value       = azurerm_kubernetes_cluster.main.kube_config[0].host
  sensitive   = true
}

output "client_certificate" {
  description = "Base64 encoded client certificate"
  value       = azurerm_kubernetes_cluster.main.kube_config[0].client_certificate
  sensitive   = true
}

output "client_key" {
  description = "Base64 encoded client key"
  value       = azurerm_kubernetes_cluster.main.kube_config[0].client_key
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64 encoded cluster CA certificate"
  value       = azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate
  sensitive   = true
}

output "oidc_issuer_url" {
  description = "OIDC issuer URL for workload identity"
  value       = azurerm_kubernetes_cluster.main.oidc_issuer_url
}

output "node_resource_group" {
  description = "Name of the node resource group"
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}

#--------------------------------------------------------------
# Identity Outputs
#--------------------------------------------------------------
output "kubelet_identity_id" {
  description = "ID of the kubelet managed identity"
  value       = azurerm_user_assigned_identity.kubelet.id
}

output "kubelet_identity_client_id" {
  description = "Client ID of the kubelet managed identity"
  value       = azurerm_user_assigned_identity.kubelet.client_id
}

output "kubelet_identity_principal_id" {
  description = "Principal ID of the kubelet managed identity"
  value       = azurerm_user_assigned_identity.kubelet.principal_id
}

output "workload_identity_id" {
  description = "ID of the workload managed identity"
  value       = azurerm_user_assigned_identity.workload.id
}

output "workload_identity_client_id" {
  description = "Client ID of the workload managed identity"
  value       = azurerm_user_assigned_identity.workload.client_id
}

output "workload_identity_principal_id" {
  description = "Principal ID of the workload managed identity"
  value       = azurerm_user_assigned_identity.workload.principal_id
}

#--------------------------------------------------------------
# Node Pool Outputs
#--------------------------------------------------------------
output "system_node_pool_name" {
  description = "Name of the system node pool"
  value       = "system"
}

output "workload_node_pool_name" {
  description = "Name of the workload node pool"
  value       = azurerm_kubernetes_cluster_node_pool.workload.name
}

output "workload_node_pool_id" {
  description = "ID of the workload node pool"
  value       = azurerm_kubernetes_cluster_node_pool.workload.id
}
