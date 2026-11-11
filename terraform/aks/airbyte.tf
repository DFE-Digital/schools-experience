module "airbyte" {
  source = "./vendor/modules/aks//aks/airbyte"

  count = var.airbyte_enabled ? 1 : 0

  environment           = var.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  service_name          = var.service_name
  docker_image          = var.docker_image
  postgres_version      = var.postgres_version
  postgres_url          = module.postgres[0].url

  host_name     = module.postgres[0].host
  database_name = module.postgres[0].name

  workspace_id      = var.airbyte_enabled ? module.infrastructure_secrets.map.AIRBYTE-WORKSPACE-ID : null
  client_id         = var.airbyte_enabled ? module.infrastructure_secrets.map.AIRBYTE-CLIENT-ID : null
  client_secret     = var.airbyte_enabled ? module.infrastructure_secrets.map.AIRBYTE-CLIENT-SECRET : null
  repl_password     = var.airbyte_enabled ? module.infrastructure_secrets.map.AIRBYTE-REPLICATION-PASSWORD : null
  server_url        = local.airbyte_server_url
  connection_status = var.connection_status

  cluster           = var.cluster
  namespace         = var.namespace
  gcp_taxonomy_id   = local.gcp_taxonomy_id
  gcp_policy_tag_id = local.gcp_policy_tag_id
  gcp_keyring       = local.gcp_keyring
  gcp_key           = local.gcp_key

  config_map_ref = module.application_configuration.kubernetes_config_map_name
  secret_ref     = module.application_configuration.kubernetes_secret_name
  cpu            = module.cluster_data.configuration_map.cpu_min

  use_azure = var.deploy_azure_backing_services
  gcp_bq_sa = var.airbyte_enabled ? module.infrastructure_secrets.map.AIRBYTE-BQ-SA : null
}

variable "airbyte_enabled" {
  type        = bool
  default     = false
  description = "Create the Airbyte source, destination and connection"
}

variable "connection_status" {
  type        = string
  default     = "inactive"
  description = "Airbyte connection status, either active or inactive"

  validation {
    condition     = contains(["active", "inactive"], var.connection_status)
    error_message = "connection_status must be either active or inactive."
  }
}

locals {
  gcp_project       = "get-into-teaching"
  gcp_keyring       = "git-key-ring"
  gcp_key           = "git-key"
  gcp_taxonomy_id   = 6582996680844371982
  gcp_policy_tag_id = 3882815557042264125

  gcp_dataset_name   = replace("${var.service_short}_airbyte_${var.environment}", "-", "_")
  airbyte_server_url = "https://airbyte-${var.namespace}.${module.cluster_data.ingress_domain}"

  airbyte_variables = var.airbyte_enabled ? {
    ENABLE_AIRBYTE           = "true"
    BIGQUERY_AIRBYTE_DATASET = local.gcp_dataset_name
    AIRBYTE_SERVER_URL       = local.airbyte_server_url
    BIGQUERY_POLICY_TAGS     = "{\"hidden\":\"projects/${local.gcp_project}/locations/europe-west2/taxonomies/${local.gcp_taxonomy_id}/policyTags/${local.gcp_policy_tag_id}\"}"
  } : {}

  airbyte_secrets = var.airbyte_enabled ? {
    AIRBYTE_CONFIGURATION = jsonencode({
      SOURCE_ID      = module.airbyte[0].airbyte_source_id
      DESTINATION_ID = module.airbyte[0].airbyte_destination_id
      CONNECTION_ID  = module.airbyte[0].airbyte_connection_id
    })
  } : {}
}
