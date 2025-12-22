# Common Module Outputs

output "naming_prefix" {
  description = "Computed naming prefix: {identifier}-{environment}-{region_abbrev}"
  value       = local.naming_prefix
}

output "region_abbreviation" {
  description = "Abbreviated region code (e.g., eus2 for eastus2)"
  value       = local.region_abbrev
}

output "tags" {
  description = "Standard tags to apply to all resources"
  value       = local.tags
}

output "identifier" {
  description = "Project or workload identifier"
  value       = var.identifier
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "location" {
  description = "Azure region"
  value       = var.location
}
