variable "cluster" {
  description = "AKS cluster where this app is deployed. Either 'test' or 'production'"
}
variable "namespace" {
  description = "AKS namespace where this app is deployed"
}
variable "environment" {
  description = "Name of the deployed environment in AKS"
}
variable "azure_credentials_json" {
  default     = null
  description = "JSON containing the service principal authentication key when running in automation"
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
variable "external_url" {
  default     = null
  description = "Healthcheck URL for StatusCake monitoring"
}
variable "statuscake_contact_groups" {
  default     = []
  description = "ID of the contact group in statuscake web UI"
}
variable "enable_monitoring" {
  default     = false
  description = "Enable monitoring and alerting"
}
variable "azure_enable_backup_storage" {
  default     = true
  description = "Create storage account for database backup"
}
variable "deploy_redis" {
  default     = true
  description = "Whether Deploy redis or not"
}

variable "deploy_postgres" {
  default     = true
  description = "Whether Deploy postgres or not"
}
variable "key_vault_name" {
  default     = null
  description = "The name of the key vault to get postgres and redis"
}
variable "key_vault_resource_group" {
  default     = null
  description = "The name of the key vault resorce group"
}
variable "review_db_dbname" {
  default     = null
  description = "The name of the secret storing review db name"
}
variable "review_db_password" {
  default     = null
  description = "The name of the secret storing review db password"
}
variable "review_db_username" {
  default     = null
  description = "The name of the secret storing review db username"
}
variable "review_db_hostname" {
  default     = null
  description = "The name of the secret storing review db host"
}
variable "review_url_redis_name" {
    default     = null
  description = "The name of the secret storing review redis url"
}
locals {
  azure_credentials = try(jsondecode(var.azure_credentials_json), null)

  postgres_ssl_mode = var.enable_postgres_ssl ? "require" : "disable"
}
