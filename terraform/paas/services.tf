data "cloudfoundry_service" "postgres" {
  name = "postgres"
}

data "cloudfoundry_service" "redis" {
  name = "redis"
}


locals {
  logstash_endpoint = local.infrastructure_secrets["LOGSTASH_ENDPOINT"]
}

resource "cloudfoundry_service_instance" "postgres" {
  count        = var.databases
  name         = var.paas_database_common_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans[var.database_plan]
  json_params  = "{\"enable_extensions\": [\"postgis\"] }"
}

resource "cloudfoundry_user_provided_service" "logging" {
  count            = var.logging
  name             = var.paas_logging_name
  space            = data.cloudfoundry_space.space.id
  syslog_drain_url = "syslog-tls://${local.logstash_endpoint}"
}

resource "cloudfoundry_service_instance" "redis" {
  count        = var.databases
  name         = var.paas_redis_1_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans[var.redis_1_plan]
  json_params  = "{\"maxmemory_policy\": \"allkeys-lfu\" }"
}

