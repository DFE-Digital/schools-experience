

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
    ENVIRONMENT_NAME = var.environment
    PGSSLMODE        = local.postgres_ssl_mode
  }
  secret_variables = {
    DB_HOST     = var.deploy_postgres ? module.postgres[0].host : "${data.azurerm_key_vault_secret.db_host[0].value}"
    DB_USERNAME = var.deploy_postgres ? module.postgres[0].username : "${data.azurerm_key_vault_secret.db_username[0].value}"
    DB_PASSWORD = var.deploy_postgres ? module.postgres[0].password : "${data.azurerm_key_vault_secret.db_password[0].value}"
    DB_DATABASE = var.deploy_postgres ? module.postgres[0].name : "${data.azurerm_key_vault_secret.db_name[0].value}"
    REDIS_URL   = var.deploy_redis ? module.redis-cache[0].url : "${data.azurerm_key_vault_secret.redis_url[0].value}"
  }
}

module "web_application" {
  source = "./vendor/modules/aks//aks/application"

  is_web = true

  namespace    = var.namespace
  environment  = var.environment
  service_name = var.service_name

  cluster_configuration_map  = module.cluster_data.configuration_map
  kubernetes_config_map_name = module.application_configuration.kubernetes_config_map_name
  kubernetes_secret_name     = module.application_configuration.kubernetes_secret_name

  docker_image = var.docker_image
  command      = ["/app/docker-entrypoint.sh", "-m", "-f"]
  probe_path   = null
  web_external_hostnames = local.web_external_hostnames
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
}
