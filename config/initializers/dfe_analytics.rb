DfE::Analytics.configure do |config|
  config.azure_federated_auth = true

  # Whether to log events instead of sending them to BigQuery.
  #
  config.log_only = false

  # Whether to use ActiveJob or dispatch events immediately.
  #
  config.async = false
  config.entity_table_checks_enabled = true

  # Which ActiveJob queue to put events on
  #
  config.queue = :analytics

  # The name of the BigQuery table we’re writing to.
  #
  # config.bigquery_table_name = ENV['BIGQUERY_TABLE_NAME']

  # The name of the BigQuery project we’re writing to.
  #
  # config.bigquery_project_id = ENV['BIGQUERY_PROJECT_ID']

  # The name of the BigQuery dataset we're writing to.
  #
  # config.bigquery_dataset = ENV['BIGQUERY_DATASET']

  # Service account JSON key for the BigQuery API. See
  # https://cloud.google.com/bigquery/docs/authentication/service-account-file
  #
  # We base64 encode the secret otherwise the raw JSON is mangled when it gets
  #  written to/read from the Azure keyvault.
  config.bigquery_api_json_key = ENV['BIGQUERY_API_JSON_KEY'] ? Base64.decode64(ENV['BIGQUERY_API_JSON_KEY']) : nil

  # Passed directly to the retries: option on the BigQuery client
  #
  # config.bigquery_retries = 3

  # Passed directly to the timeout: option on the BigQuery client
  #
  # config.bigquery_timeout = 120

  # A proc which returns true or false depending on whether you want to
  # enable analytics. You might want to hook this up to a feature flag or
  # environment variable.
  #
  config.enable_analytics = proc { Rails.application.config.x.dfe_analytics }

  config.user_identifier = proc { |user| user&.sub }

  # The environment we’re running in. This value will be attached
  # to all events we send to BigQuery.
  #
  # config.environment = ENV.fetch('RAILS_ENV', 'development')

  config.bigquery_maintenance_window = "08-09-2024 18:00..08-09-2024 19:00"



  # The name of the BigQuery table we’re writing to.
  #
  config.bigquery_table_name = 'events'

  # The name of the BigQuery project we’re writing to.
  #
  config.bigquery_project_id = 'get-into-teaching'

  # The name of the BigQuery dataset we're writing to.
  #
  config.bigquery_dataset = 'gse_events_staging'

  # Ensure JSON API Key does not get set
  config.bigquery_api_json_key = ''

  config.google_cloud_credentials = {
    universe_domain: "googleapis.com",
    type: "external_account",
    audience: "//iam.googleapis.com/projects/574582782335/locations/global/workloadIdentityPools/azure-cip-identity-pool/providers/azure-cip-oidc-provider",
    subject_token_type: "urn:ietf:params:oauth:token-type:jwt",
    token_url: "https://sts.googleapis.com/v1/token",
    credential_source: {
      url: "https://login.microsoftonline.com/9c7d9dd3-840c-4b3f-818e-552865082e16/oauth2/v2.0/token"
    },
    service_account_impersonation_url: "https://iamcredentials.googleapis.com/v1/projects/-/serviceAccounts/bat-cross-project@get-into-teaching.iam.gserviceaccount.com:generateAccessToken",
    service_account_impersonation: {
      token_lifetime_seconds: 3600
    }
  }
end
