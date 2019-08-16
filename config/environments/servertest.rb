require File.expand_path('production.rb', __dir__)
require File.join(Rails.root, 'spec', 'support', 'notify_fake_client')
require Rails.root.join("lib", "servertest", "geocoder")

Rails.application.configure do
  # Override production environment settings here

  # Don't actually attempt to delivery emails in Staging environment
  config.x.notify_client = NotifyFakeClient

  # default to true but allow overriding in CI
  config.force_ssl = !ENV['SKIP_FORCE_SSL'].present?

  config.x.phase = 10000
  config.x.features = %i(subject_specific_dates dbs_requirement)

  # dfe signin config, should be in credentials or env vars
  config.x.base_url = "https://localhost:#{ENV.fetch("PORT") { 3000 }}"
  config.x.oidc_client_id = 'schoolexperience'
  config.x.oidc_client_secret = Rails.application.credentials.dig(:dfe_pp_signin_secret)
  config.x.oidc_host = 'pp-oidc.signin.education.gov.uk'
  config.x.oidc_services_list_url = 'https://some-oidc.provider.com/my-services'

  config.x.gitis.fake_crm = true
  config.x.gitis.channel_creation = '0'
  config.x.gitis.owner_id = SecureRandom.uuid
  config.x.gitis.country_id = SecureRandom.uuid
end
