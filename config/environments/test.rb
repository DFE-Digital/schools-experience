require Rails.root.join('spec', 'support', 'notify_fake_client')

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.cache_classes = true

  # Do not eager load code on boot. This avoids loading your whole application
  # just for the purpose of running a single test. If you are using a tool that
  # preloads Rails for running tests, you may have to set it to true.
  config.eager_load = false

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # avoid second pass through SASS since thats incompatible with GovUK Frontend
  config.assets.css_compressor = nil

  # set the cache to use RAM
  config.cache_store = :null_store

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Use Redis for Session and cache
  config.cache_store = :redis_cache_store, {
    url: ENV['REDIS_URL'].presence,
    db: ENV['TEST_ENV_NUMBER'].presence, # Note DB overrides db in URL if both specified
    namespace: 'test-cache'
  }

  config.session_store :cache_store,
    key: 'schoolex-test-session',
    expire_after: 1.hour # Sets explicit TTL for Session Redis keys

  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true

  # Use the test adapter for active jobs
  config.active_job.queue_adapter = :test

  config.after_initialize do
    Bullet.enable = true
    Bullet.raise = true
  end

  # Don't actually attempt to delivery emails during tests
  config.x.notify_client = NotifyFakeClient

  config.x.phase = 10000
  config.x.features = %i[
    subject_specific_dates
    capped_bookings
    reminders
  ]
  config.x.candidates.disable_applications = false
  config.x.candidates.alert_notification = nil
  config.x.bing_maps_key = nil

  config.x.base_url = 'https://some-host'
  config.x.oidc_client_id = 'se-test'
  config.x.oidc_client_secret = 'abc123'
  config.x.oidc_host = 'some-oidc-host.education.gov.uk'
  config.x.oidc_services_list_url = 'https://some-oidc.provider.com/my-services'
  config.x.dfe_sign_in_api_host = 'some-signin-host.signin.education.gov.uk'
  config.x.dfe_sign_in_admin_service_id = '66666666-5555-aaaa-bbbb-cccccccccccc'
  config.x.dfe_sign_in_admin_role_id = '66666666-5555-4444-3333-222222222222'
  config.x.dfe_sign_in_api_enabled = false
  config.x.dfe_sign_in_api_role_check_enabled = false
  config.x.dfe_sign_in_api_school_change_enabled = false

  config.x.gitis.fake_crm = true
  config.x.gitis.channel_creation = '0'
  config.x.gitis.country_id = SecureRandom.uuid
  config.x.gitis.privacy_policy_id = SecureRandom.uuid
  config.x.gitis.privacy_consent_id = '10'
  config.x.gitis.caching = false

  Rails.application.routes.default_url_options = { protocol: 'https' }
  config.ab_threshold = Integer ENV.fetch('AB_TEST_THRESHOLD', 100)

  config.x.maintenance_mode = false
end
