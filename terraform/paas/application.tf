locals {
  environment_map = { REDIS_URL = local.redis-credentials.uri,
    DB_DATABASE        = local.postgres-credentials.name
    DB_HOST            = local.postgres-credentials.host,
    DB_USERNAME        = local.postgres-credentials.username,
    DB_PASSWORD        = local.postgres-credentials.password,
    SKIP_FORCE_SSL     = true,
    SENTRY_CURRENT_ENV = var.application_environment,
    SLACK_ENV          = var.application_environment
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

  dynamic "service_binding" {
    for_each = data.cloudfoundry_user_provided_service.logging
    content {
      service_instance = service_binding.value["id"]
    }
  }

  routes {
    route = cloudfoundry_route.route_cloud.id
  }

  routes {
    route = cloudfoundry_route.route_internal.id
  }

  dynamic "routes" {
    for_each = data.cloudfoundry_route.app_route_internet
    content {
      route = routes.value["id"]
    }
  }

  environment = merge(local.application_secrets, local.environment_map)

}

