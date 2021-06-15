locals {
  environment_map = { REDIS_URL = local.redis-credentials.uri,
    DB_DATABASE    = local.postgres-credentials.name 
    DB_HOST        = local.postgres-credentials.host,
    DB_USERNAME    = local.postgres-credentials.username,
    DB_PASSWORD    = local.postgres-credentials.password,
    SKIP_FORCE_SSL = true,
  }
}

resource "cloudfoundry_app" "application" {
  name         = var.paas_application_name
  space        = data.cloudfoundry_space.space.id
  docker_image = var.paas_docker_image
  stopped      = var.application_stopped
  instances    = var.application_instances
  memory       = var.application_memory
  disk_quota   = var.application_disk
  strategy     = var.strategy

  routes {
    route = cloudfoundry_route.route_cloud.id
  }

  routes {
    route = cloudfoundry_route.route_internal.id
  }

  environment = merge(local.application_secrets, local.environment_map)

}
