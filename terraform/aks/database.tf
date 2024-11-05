module "postgres" {
  count  = 1
  source = "./vendor/modules/aks//aks/postgres"

  namespace                   = var.namespace
  environment                 = var.environment
  azure_resource_prefix       = var.azure_resource_prefix
  service_name                = var.service_name
  service_short               = var.service_short
  config_short                = var.config_short
  cluster_configuration_map   = module.cluster_data.configuration_map
  use_azure                   = var.deploy_azure_backing_services
  azure_enable_monitoring     = var.enable_monitoring
  server_version              = "14"
  azure_sku_name          = var.postgres_flexible_server_sku
  azure_enable_backup_storage = var.azure_enable_backup_storage
  azure_extensions            = ["POSTGIS", "address_standardizer", "plpgsql", "postgis_raster", "uuid-ossp", "citext"]
  azure_enable_high_availability = var.postgres_enable_high_availability
  azure_maintenance_window       = var.azure_maintenance_window
  server_docker_image         = "postgis/postgis:14-3.4"
  create_database = var.create_database
}

module "redis-cache" {
  count  = 1
  source = "./vendor/modules/aks//aks/redis"

  namespace                 = var.namespace
  environment               = var.environment
  azure_resource_prefix     = var.azure_resource_prefix
  service_short             = var.service_short
  config_short              = var.config_short
  service_name              = var.service_name
  cluster_configuration_map = module.cluster_data.configuration_map
  use_azure                 = var.deploy_azure_backing_services
  azure_enable_monitoring   = var.enable_monitoring
  azure_patch_schedule      = [{ "day_of_week" : "Sunday", "start_hour_utc" : 01 }]
  azure_maxmemory_policy    = "noeviction"
}
