# These settings are for the sandbox and should mainly be overriden by TF_VARS
# or set with environment variables TF_VAR_xxxx

variable "api_url" {
  default = "https://api.london.cloud.service.gov.uk"
}

variable "AZURE_CREDENTIALS" {
default = "{}"
}

variable "azure_key_vault" {}
variable "azure_resource_group" {}

variable "logging" {
  default = 1
}

variable "databases" {
  default = 1
}

variable "paas_internet_hostnames" {
  default = []
}

variable "FRONTEND" {
  default = "migrate frontend"
}

variable "BACKGROUND" {
  default = "background"
}

variable "strategy" {
  default = "blue-green-v2"
}

variable "application_instances" {
  default = 1
}

variable "delayed_job_instances" {
  default = 1
}

variable "application_stopped" {
  default = false
}

variable "application_memory" {
  default = "1024"
}

variable "application_disk" {
  default = "2048"
}

variable "paas_space" {
  default = "sandbox"
}

variable "paas_monitoring_space" {
  default = "sandbox"
}

variable "paas_monitoring_app" {
  default = ""
}

variable "environment" {
  default = "sb"
}

variable "paas_org_name" {
  default = "dfe"
}

variable "paas_logging_name" {
  default = "logit-ssl-drain"
}

variable "paas_database_common_name" {
  default = "dfe-school-experience-sb-common-pg-svc"
}

variable "database_plan" {
  default = "small-11"
}

variable "paas_redis_1_name" {
  default = "dfe-school-experience-sb-redis-svc"
}

variable "redis_1_plan" {
  default = "micro-ha-5_x"
}

variable "redis_service_key" {
  default = "redis_service_key"
}

variable "postgres_service_key" {
  default = "postgres_service_key"
}

variable "application_environment" {
  default = "dfe-school-experience-development"
}

variable "paas_application_name" {
  default = "dfe-school-experience-app"
}

variable "static_route" {
  default = ""
}

variable "paas_docker_image" {
  default = "ghcr.io/dfe-digital/schools-experience:master"
}

variable "alerts" {
  type    = map(any)
  default = {}
}

variable "statuscake_enable_basic_auth" {
  type    = bool
  default = false
}

variable "timeout" {
  default = 180
}
