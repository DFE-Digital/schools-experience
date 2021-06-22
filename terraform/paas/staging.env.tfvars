paas_space                = "get-into-teaching-test"            # Currently Set to Development while waiting on Staging Service Now ticket to be actioned
paas_database_common_name = "school-experience-staging-pg-common-svc"
paas_redis_1_name         = "school-experience-staging-redis-svc"
paas_application_name     = "school-experience-app-staging"
paas_internet_hostnames   = []
application_instances     = 1
environment               = "staging"
azure_key_vault           = "s105d01-kv"                        # Currently Set to Development while waiting on Staging Service Now ticket to be actioned
azure_resource_group      = "s105d01-dev-vault-resource-group"  # Currently Set to Development while waiting on Staging Service Now ticket to be actioned
alerts = {
  SchoolExperience_Staging = {
    website_name  = "School Experience (Staging)"
    website_url   = "https://school-experience-app-staging.london.cloudapps.digital/healthcheck.json"
    test_type     = "HTTP"
    check_rate    = 60
    contact_group = [185037]
    trigger_rate  = 0
    confirmations = 2
    node_locations = ["UKINT", "UK1", "MAN1", "MAN5", "DUB2"]
  }
}
