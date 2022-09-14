paas_space                = "get-into-teaching-test"
paas_monitoring_space     = "get-into-teaching-monitoring"
paas_monitoring_app       = "prometheus-prod-get-into-teaching"
paas_database_common_name = "school-experience-staging-pg-common-svc"
paas_redis_1_name         = "school-experience-staging-redis-svc"
paas_application_name     = "school-experience-app-staging"
paas_internet_hostnames   = ["staging-schoolexperience","schoolexperience-staging"]
application_instances     = 1
sidekiq_job_instances     = 2
environment               = "staging"
application_environment   = "dfe-school-experience-staging"
database_plan             = "small-13"
azure_key_vault           = "s105t01-kv"
azure_resource_group      = "s105t01-staging-vault-resource-group"

statuscake_enable_basic_auth = true
alerts = {
  SchoolExperience_Staging = {
    website_name   = "School Experience (Staging)"
    website_url    = "https://school-experience-app-staging.london.cloudapps.digital/healthcheck.json"
    check_rate     = 60
    contact_group  = [239498]
  }
}
