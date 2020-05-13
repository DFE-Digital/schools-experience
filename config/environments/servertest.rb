require File.expand_path('production.rb', __dir__)
require Rails.root.join('spec', 'support', 'notify_fake_client')
require Rails.root.join("lib", "servertest", "geocoder")
require Rails.root.join("lib", "servertest", "dfe_sign_in_api")

Rails.application.configure do
  # Override production environment settings here

  # Don't actually attempt to delivery emails in Staging environment
  config.x.notify_client = NotifyFakeClient

  # default to true but allow overriding in CI
  config.force_ssl = ENV['SKIP_FORCE_SSL'].blank?

  config.x.phase = 10000
  config.x.features = %i[
    subject_specific_dates
    capped_bookings
    reminders
  ]
  config.x.candidates.disable_applications = false
  config.x.candidates.alert_notification = nil
  config.x.bing_maps_key = nil

  # dfe signin config, should be in credentials or env vars
  config.x.base_url = "https://localhost:#{ENV.fetch('PORT') { 3000 }}"
  config.x.oidc_client_id = 'schoolexperience'
  config.x.oidc_client_secret = Rails.application.credentials.dig(:dfe_pp_signin_secret)
  config.x.oidc_host = 'pp-oidc.signin.education.gov.uk'
  config.x.oidc_services_list_url = 'https://some-oidc.provider.com/my-services'
  config.x.dfe_sign_in_api_host = 'pp-api.signin.education.gov.uk'
  config.x.dfe_sign_in_api_enabled = false
  config.x.dfe_sign_in_api_role_check_enabled = false
  config.x.dfe_sign_in_api_school_change_enabled = false

  config.x.gitis.fake_crm = true
  config.x.gitis.channel_creation = '0'
  config.x.gitis.country_id = SecureRandom.uuid
  config.x.gitis.privacy_policy_id = SecureRandom.uuid
  config.x.gitis.privacy_consent_id = '10'
  config.x.gitis.caching = false

  config.ab_threshold = Integer ENV.fetch('AB_TEST_THRESHOLD', 100)

  config.x.maintenance_mode = false
end
