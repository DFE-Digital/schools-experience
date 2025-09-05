require "active_support/core_ext/integer/time"

require Rails.root.join('spec', 'support', 'notify_fake_client')
require Rails.root.join('spec', 'support', 'fake_get_into_teaching_api_client')

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Verifies that versions and hashed value of the package contents in the project's package.json
  config.shakapacker.check_yarn_integrity = false

  # Settings specified here will take precedence over those in config/application.rb.

  # While tests run files are not watched, reloading is not necessary.
  config.enable_reloading = false

  # Eager loading loads your entire application. When running a single test locally,
  # this is usually not necessary, and can slow down your test suite. However, it's
  # recommended that you enable it in continuous integration systems to ensure eager
  # loading is working properly before deploying your code.
  config.eager_load = ENV["CI"].present?

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    "X-Content-Type-Options" => "nosniff",
    "Cache-Control" => "public, max-age=#{1.hour.to_i}"
  }

  # Include generic and useful information about system operation, but avoid logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII).
  config.log_level = :info

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id, ->(_) { "PID:#{Process.pid}" }]

  # Show full error reports and disable caching.
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = false
  config.cache_store = :null_store

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Raises error for missing translations.
  config.i18n.raise_on_missing_translations = true

  # Render exception templates for rescuable exceptions and raise for other exceptions.
  config.action_dispatch.show_exceptions = :rescuable

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []


  # Use Redis for Session and cache
  config.cache_store = :redis_cache_store,
    {
      url: ENV['REDIS_URL'].presence,
      db: ENV['TEST_ENV_NUMBER'].presence, # Note DB overrides db in URL if both specified
      namespace: 'test-cache'
    }

  config.session_store :cache_store,
    key: 'schoolex-test-session',
    expire_after: 1.hour # Sets explicit TTL for Session Redis keys

  # Raise exceptions instead of rendering exception templates.
  config.action_dispatch.show_exceptions = false

  # Use the test adapter for active jobs
  config.active_job.queue_adapter = :test

  config.force_ssl = false

  Rails.application.routes.default_url_options = { protocol: 'https' }

  # We get a foreign key error on the CI run if this is enabled; I think
  # our fixtures are actually fine and its masking another exception. We
  # should look to enable this to be inline with the Rails 7 defaults at
  # some point.
  config.active_record.verify_foreign_keys_for_fixtures = false

  # Don't actually attempt to delivery emails during tests
  config.x.notify_client = 'NotifyFakeClient'

  config.x.candidates.deactivate_applications = false
  config.x.candidates.disable_applications = false
  config.x.candidates.alert_notification = nil
  config.x.google_maps_key = nil

  config.x.base_url = 'https://some-host'
  config.x.oidc_client_id = 'se-test'
  config.x.oidc_client_secret = 'abc123'
  config.x.oidc_host = 'some-oidc-host.education.gov.uk'

  config.x.dfe_sign_in_api_host = 'some-signin-host.signin.education.gov.uk'

  config.x.dfe_sign_in_api_enabled = false
  config.x.dfe_sign_in_api_role_check_enabled = false
  config.x.dfe_sign_in_api_school_change_enabled = false
  config.x.dfe_sign_in_admin_service_id = '66666666-5555-aaaa-bbbb-cccccccccccc'
  config.x.dfe_sign_in_admin_role_id = '66666666-5555-4444-3333-222222222222'
  config.x.dfe_sign_in_request_organisation_url = nil
  config.x.dfe_sign_in_manage_users_url = nil
  config.x.dfe_sign_in_add_service_url = nil

  config.x.gitis.privacy_consent_id = '10'

  config.ab_threshold = Integer ENV.fetch('AB_TEST_THRESHOLD', 100)

  config.x.maintenance_mode = false

  config.x.git_api_endpoint = "https://fake-git.api/api"
  config.x.api_client_cache_store = ActiveSupport::Cache::MemoryStore.new

  config.x.dfe_analytics = true

  config.after_initialize do
    Bullet.enable = true
    Bullet.raise = true
    Bullet.unused_eager_loading_enable = false
  end

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true
end
