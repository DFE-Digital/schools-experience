data "cloudfoundry_service" "postgres" {
  name = "postgres"
}

data "cloudfoundry_service" "redis" {
  name = "redis"
}


locals {
  # logstash_endpoint = local.infrastructure_secrets["LOGSTASH_ENDPOINT"]
  logstash_endpoint = ""
}

resource "cloudfoundry_service_instance" "postgres" {
  count        = var.databases
  name         = var.paas_database_common_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans[var.database_plan]
  json_params  = "{\"enable_extensions\": [\"postgis\"] }"
}

resource "cloudfoundry_service_key" "postgres-key1" {
  count            = var.databases
  name             = var.postgres_service_key
  service_instance = cloudfoundry_service_instance.postgres[0].id
}

data "cloudfoundry_service_instance" "postgres" {
  count      = 1 - var.databases
  name_or_id = var.paas_database_common_name
  space      = data.cloudfoundry_space.space.id
}

data "cloudfoundry_service_key" "postgres-key1" {
  count            = 1 - var.databases
  name             = var.postgres_service_key
  service_instance = data.cloudfoundry_service_instance.postgres[0].id
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

resource "cloudfoundry_service_key" "redis1-key1" {
  count            = var.databases
  name             = var.redis_service_key
  service_instance = cloudfoundry_service_instance.redis[0].id
}

data "cloudfoundry_service_instance" "redis" {
  count      = 1 - var.databases
  name_or_id = var.paas_redis_1_name
  space      = data.cloudfoundry_space.space.id
}

data "cloudfoundry_service_key" "redis1-key1" {
  count            = 1 - var.databases
  name             = var.redis_service_key
  service_instance = data.cloudfoundry_service_instance.redis[0].id
}

locals {
  redis-credentials    = var.databases == 1 ? cloudfoundry_service_key.redis1-key1[0].credentials : data.cloudfoundry_service_key.redis1-key1[0].credentials
  postgres-credentials = var.databases == 1 ? cloudfoundry_service_key.postgres-key1[0].credentials : data.cloudfoundry_service_key.postgres-key1[0].credentials
}
