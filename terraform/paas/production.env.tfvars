paas_space                = "get-into-teaching-production"
paas_monitoring_space     = "get-into-teaching-monitoring"
paas_monitoring_app       = "prometheus-prod-get-into-teaching"
paas_database_common_name = "school-experience-prod-pg-common-svc"
paas_redis_1_name         = "school-experience-prod-redis-svc"
paas_application_name     = "school-experience-app-production"
paas_internet_hostnames   = ["schoolexperience"]
application_instances     = 2
application_memory        = 2046
delayed_jobs              = 1
environment               = "production"
application_environment   = "dfe-school-experience-production"
azure_key_vault           = "s105p01-kv"
azure_resource_group      = "s105p01-prod-vault-resource-group"
database_plan             = "small-ha-11"
redis_1_plan              = "micro-ha-5_x"

alerts = {
  SchoolExperience_Production = {
    website_name   = "School Experience (Production)"
    website_url    = "https://schoolexperience.education.gov.uk/healthcheck.json"
    test_type      = "HTTP"
    check_rate     = 60
    contact_group  = [239498]
    trigger_rate   = 0
    confirmations  = 2
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
  }
}
