require File.expand_path('production.rb', __dir__)
require File.join(Rails.root, 'spec', 'support', 'notify_fake_client')
require Rails.root.join("lib", "servertest", "geocoder")

# Override the create method in the sessions controller for simplier (OIDC-free)
# access during testing
require Rails.root.join("features", "support", "sessions_controller")

Rails.application.configure do
  # Override production environment settings here

  # Don't actually attempt to delivery emails in Staging environment
  Notify.notification_class = NotifyFakeClient

  # default to true but allow overriding in CI
  config.force_ssl = !ENV['SKIP_FORCE_SSL'].present?

  config.x.phase_two.enabled = true

  # dfe signin config, should be in credentials or env vars
  config.x.base_url = "https://localhost:#{ENV.fetch("PORT") { 3000 }}"
  config.x.oidc_client_id = 'schoolexperience'
  config.x.oidc_client_secret = Rails.application.credentials.dig(:dfe_pp_signin_secret)
  config.x.oidc_host = 'pp-oidc.signin.education.gov.uk'
end
