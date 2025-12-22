# Common Module - Naming, Tags, and Region Mappings

locals {
  # Region abbreviation mapping
  region_abbreviations = {
    "eastus"             = "eus"
    "eastus2"            = "eus2"
    "westus"             = "wus"
    "westus2"            = "wus2"
    "centralus"          = "cus"
    "northcentralus"     = "ncus"
    "southcentralus"     = "scus"
    "westcentralus"      = "wcus"
    "canadacentral"      = "cac"
    "canadaeast"         = "cae"
    "brazilsouth"        = "brs"
    "northeurope"        = "neu"
    "westeurope"         = "weu"
    "uksouth"            = "uks"
    "ukwest"             = "ukw"
    "francecentral"      = "frc"
    "francesouth"        = "frs"
    "germanywestcentral" = "gwc"
    "switzerlandnorth"   = "chn"
    "norwayeast"         = "noe"
    "swedencentral"      = "sec"
    "australiaeast"      = "aue"
    "australiasoutheast" = "ause"
    "southeastasia"      = "sea"
    "eastasia"           = "ea"
    "japaneast"          = "jpe"
    "japanwest"          = "jpw"
    "koreacentral"       = "krc"
    "koreasouth"         = "krs"
    "centralindia"       = "inc"
    "southindia"         = "ins"
    "westindia"          = "inw"
  }

  # Get region abbreviation or use location as fallback
  region_abbrev = lookup(local.region_abbreviations, var.location, var.location)

  # Computed naming prefix
  naming_prefix = "${var.identifier}-${var.environment}-${local.region_abbrev}"

  # Standard tags applied to all resources
  standard_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Identifier  = var.identifier
    Region      = var.location
  }

  # Merge standard tags with additional tags
  tags = merge(local.standard_tags, var.additional_tags)
}
