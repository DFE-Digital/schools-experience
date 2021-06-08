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

  dynamic "service_binding" {
    for_each = concat( cloudfoundry_service_instance.redis , cloudfoundry_service_instance.postgres , cloudfoundry_user_provided_service.logging ) 
    content {
      service_instance = service_binding.value["id"]
    }
  }

#  environment = merge(local.application_secrets, local.environment_map)

}




