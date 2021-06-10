locals {
  environment_map = { REDIS_URL = local.redis-credentials.uri,
    DATABASE_URL   = local.postgres-credentials.uri,
    DB_DATABASE    = "schools-experience",
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

  # For Review Apps find existing Resources
  dynamic "service_binding" {
    for_each = concat(data.cloudfoundry_service_instance.redis, data.cloudfoundry_service_instance.redis)
    content {
      service_instance = service_binding.value["id"]
    }
  }

  # For Dev/Test/Production Apps use created Resources
  dynamic "service_binding" {
    for_each = concat(cloudfoundry_service_instance.redis, cloudfoundry_service_instance.postgres, cloudfoundry_user_provided_service.logging)
    content {
      service_instance = service_binding.value["id"]
    }
  }

  environment = merge(local.application_secrets, local.environment_map)

}
