module "application_configuration" {
  source = "./vendor/modules/aks//aks/application_configuration"

  namespace              = var.namespace
  environment            = var.environment
  azure_resource_prefix  = var.azure_resource_prefix
  service_short          = var.service_short
  config_short           = var.config_short
  secret_key_vault_short = "app"
  # Delete for non rails apps
  is_rails_application = true

  config_variables = {
    ENVIRONMENT_NAME    = var.environment
    PGSSLMODE           = local.postgres_ssl_mode
    DFE_SIGNIN_BASE_URL = "https://${var.dsi_hostname}"
    BIGQUERY_PROJECT_ID = "get-into-teaching"
    BIGQUERY_TABLE_NAME = "events"
    BIGQUERY_DATASET    = var.dataset_name
  }
  secret_variables = {
    DATABASE_URL = module.postgres[0].url
    REDIS_URL    = module.redis-cache[0].url

    GOOGLE_CLOUD_CREDENTIALS = var.enable_dfe_analytics_federated_auth ? module.dfe_analytics[0].google_cloud_credentials : null
  }
}

module "web_application" {
  source = "./vendor/modules/aks//aks/application"

  is_web = true

  namespace                  = var.namespace
  environment                = var.environment
  service_name               = var.service_name
  replicas                   = var.app_replicas
  cluster_configuration_map  = module.cluster_data.configuration_map
  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name

  docker_image           = var.docker_image
  command                = var.webapp_command
  probe_path             = "/check"
  web_external_hostnames = var.create_dsi_ingress ? [var.dsi_hostname] : []
  enable_logit           = var.enable_logit

  enable_prometheus_monitoring = var.enable_prometheus_monitoring
}

module "worker_application" {
  source                     = "./vendor/modules/aks//aks/application"
  name                       = "worker"
  is_web                     = false
  namespace                  = var.namespace
  environment                = local.app_name_suffix
  service_name               = var.service_name
  cluster_configuration_map  = module.cluster_data.configuration_map
  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name
  docker_image               = var.docker_image
  command                    = ["/bin/sh", "-c", "bundle exec sidekiq -C config/sidekiq.yml"]
  max_memory                 = var.sidekiq_memory_max
  replicas                   = var.sidekiq_replicas
  enable_logit               = var.enable_logit

  enable_prometheus_monitoring     = var.enable_prometheus_monitoring
  send_traffic_to_maintenance_page = var.send_traffic_to_maintenance_page
  enable_gcp_wif                   = true
}
