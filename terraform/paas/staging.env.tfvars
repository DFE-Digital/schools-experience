paas_space                = "get-into-teaching-test"
paas_monitoring_space     = "get-into-teaching-monitoring"
paas_monitoring_app       = "prometheus-prod-get-into-teaching"
paas_database_common_name = "school-experience-staging-pg-common-svc"
paas_redis_1_name         = "school-experience-staging-redis-svc"
paas_application_name     = "school-experience-app-staging"
paas_internet_hostnames   = ["staging-schoolexperience","schoolexperience-staging"]
application_instances     = 1
delayed_jobs              = 1
environment               = "staging"
application_environment   = "dfe-school-experience-staging"
azure_key_vault           = "s105t01-kv"
azure_resource_group      = "s105t01-staging-vault-resource-group"
database_plan             = "small-13"

alerts = {
  SchoolExperience_Staging = {
    website_name   = "School Experience (Staging)"
    website_url    = "https://school-experience-app-staging.london.cloudapps.digital/healthcheck.json"
    test_type      = "HTTP"
    check_rate     = 60
    contact_group  = [239498]
    trigger_rate   = 0
    confirmations  = 2
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
  }
}
