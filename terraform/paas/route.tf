data "cloudfoundry_route" "app_route_internet" {
  for_each = toset(var.paas_internet_hostnames)
  hostname = each.value
  domain   = data.cloudfoundry_domain.internet.id
}

resource "cloudfoundry_route" "route_cloud" {
  domain   = data.cloudfoundry_domain.cloudapps.id
  hostname = var.paas_application_name
  space    = data.cloudfoundry_space.space.id

}

resource "cloudfoundry_route" "route_internal" {
  domain   = data.cloudfoundry_domain.internal.id
  hostname = "${var.paas_application_name}-internal"
  space    = data.cloudfoundry_space.space.id
}

locals {
  app_endpoint = "${cloudfoundry_route.route_cloud.hostname}.${data.cloudfoundry_domain.cloudapps.name}"
}
