variable "app_name_suffix" { default = null }

variable "postgres_version" { default = 14 }

# PaaS variables
variable "paas_app_environment" {}

# Key Vault variables
variable "azure_credentials" { default = null }

variable "key_vault_name" {}

variable "key_vault_infra_secret_name" {}

variable "key_vault_app_secret_name" {}

# Kubernetes variables
variable "namespace" {}

variable "cluster" {}

variable "enable_monitoring" { default = true }

variable "azure_resource_prefix" {}

variable "config_short" {}
variable "service_short" {}

variable "service_name" {}

variable "azure_maintenance_window" { default = null }
variable "postgres_flexible_server_sku" { default = "B_Standard_B1ms" }
variable "postgres_enable_high_availability" { default = false }
variable "azure_enable_backup_storage" { default = true }

locals {
  app_name_suffix  = var.paas_app_environment

  azure_credentials = try(jsondecode(var.azure_credentials), null)
}