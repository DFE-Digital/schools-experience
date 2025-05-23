variable "cluster" {
  description = "AKS cluster where this app is deployed. Either 'test' or 'production'"
}

variable "app_name" { default = null }
variable "namespace" {
  description = "AKS namespace where this app is deployed"
}
variable "environment" {
  description = "Name of the deployed environment in AKS"
}
variable "azure_resource_prefix" {
  description = "Standard resource prefix. Usually s189t01 (test) or s189p01 (production)"
}
variable "config_short" {
  description = "Short name of the environment configuration, e.g. dv, st, pd..."
}
variable "service_name" {
  description = "Full name of the service. Lowercase and hyphen separated"
}
variable "service_short" {
  description = "Short name to identify the service. Up to 6 charcters."
}
variable "deploy_azure_backing_services" {
  default     = true
  description = "Deploy real Azure backing services like databases, as opposed to containers inside of AKS"
}
variable "enable_postgres_ssl" {
  default     = true
  description = "Enforce SSL connection from the client side"
}
variable "docker_image" {
  description = "Docker image full name to identify it in the registry. Includes docker registry, repository and tag e.g.: ghcr.io/dfe-digital/teacher-pay-calculator:673f6309fd0c907014f44d6732496ecd92a2bcd0"
}

variable "sidekiq_memory_max" {
  description = "maximum memory of the sidekiq"
}

variable "sidekiq_replicas" {
  description = "number of replicas of the sidekiq"
}

variable "app_replicas" {
  description = "number of replicas of the web app"
  default     = 1
}
variable "enable_dfe_analytics_federated_auth" {
  description = "Create the resources in Google cloud for federated authentication and enable in application"
  default     = false
}
variable "dataset_name" {
  description = "dfe analytics dataset name in Google Bigquery"
}

variable "enable_monitoring" {
  default     = false
  description = "Enable monitoring and alerting"
}
variable "azure_enable_backup_storage" {
  default     = true
  description = "Create storage account for database backup"
}

variable "infra_key_vault_name" {
  default     = null
  description = "The name of the key vault to get postgres and redis"
}
variable "key_vault_resource_group" {
  default     = null
  description = "The name of the key vault resorce group"
}
variable "azure_maintenance_window" {
  default = null
}
variable "postgres_flexible_server_sku" {
  default = "B_Standard_B1ms"
}
variable "postgres_enable_high_availability" {
  default = false
}

variable "statuscake_alerts" {
  type = map(
    object({
      website_url    = optional(list(string), [])
      ssl_url        = optional(list(string), [])
      contact_groups = optional(list(number), [])
    })
  )
  default = {}
}

variable "statuscake_password_name" {
  default     = "SC-PASSWORD"
  description = "The name of the statuscake password"
}
variable "dsi_hostname" {
  description = "The static hostname for DFE sign-in "
  default     = ""
}
variable "create_dsi_ingress" {
  description = "Optional additional ingress for DSI hostname when front door is not used"
  default     = false
}
variable "enable_logit" { default = false }
variable "enable_prometheus_monitoring" {
  type    = bool
  default = false
}
variable "webapp_command" {
  default     = ["/app/docker-entrypoint.sh", "-m", "-f"]
  description = "Start command to initialise and run the web app"
}
variable "create_database" {
  default = true
}
variable "send_traffic_to_maintenance_page" {
  description = "During a maintenance operation, keep sending traffic to the maintenance page instead of resetting the ingress"
  type        = bool
  default     = false
}
locals {
  postgres_ssl_mode = var.enable_postgres_ssl ? "require" : "disable"
  app_name_suffix   = var.app_name == null ? var.environment : var.app_name
}
