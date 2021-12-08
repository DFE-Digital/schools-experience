require File.expand_path('production.rb', __dir__)
require Rails.root.join('spec', 'support', 'notify_fake_client')
require Rails.root.join("lib", "servertest", "geocoder")
require Rails.root.join("lib", "servertest", "dfe_sign_in_api")

Rails.application.configure do
  # Override production environment settings here

  # Don't actually attempt to delivery emails in Staging environment
  config.x.notify_client = 'NotifyFakeClient'

  # default to true but allow overriding in CI
  config.force_ssl = ENV['SKIP_FORCE_SSL'].blank?

  config.x.phase = 10_000
  config.x.features = %i[
    subject_specific_dates
    capped_bookings
    reminders
  ]
  config.x.candidates.disable_applications = false
  config.x.candidates.alert_notification = nil
  config.x.google_maps_key = nil

  # dfe signin config, should be in credentials or env vars
  config.x.base_url = "https://localhost:#{ENV.fetch('PORT', 3000)}"
  config.x.oidc_client_id = 'schoolexperience'
  config.x.oidc_client_secret = Rails.application.credentials[:dfe_pp_signin_secret]
  config.x.oidc_host = 'pp-oidc.signin.education.gov.uk'
  config.x.dfe_sign_in_api_host = 'pp-api.signin.education.gov.uk'
  config.x.dfe_sign_in_api_enabled = false
  config.x.dfe_sign_in_api_role_check_enabled = false
  config.x.dfe_sign_in_api_school_change_enabled = false
  config.x.dfe_sign_in_request_organisation_url = ""
  config.x.dfe_sign_in_request_service_url = ""
  config.x.dfe_sign_in_add_service_url = ""

  config.x.gitis.privacy_consent_id = '10'

  config.ab_threshold = Integer ENV.fetch('AB_TEST_THRESHOLD', 100)

  config.x.maintenance_mode = false

  config.x.git_api_endpoint = "https://fake-git.api/api"
  config.x.api_client_cache_store = ActiveSupport::Cache::MemoryStore.new
end
