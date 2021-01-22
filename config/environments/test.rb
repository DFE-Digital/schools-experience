require "active_support/core_ext/integer/time"

require Rails.root.join('spec', 'support', 'notify_fake_client')

# The test environment is used exclusively to run your application's
# test suite. You never need to work with it otherwise. Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs. Don't rely on the data there!

Rails.application.configure do
  # Verifies that versions and hashed value of the package contents in the project's package.json
  config.webpacker.check_yarn_integrity = false

  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both threaded web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable request forgery protection in test environment.
  config.action_controller.allow_forgery_protection = false

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Configure public file server for tests with Cache-Control for performance.
  config.public_file_server.enabled = true
  config.public_file_server.headers = {
    'X-Content-Type-Options' => 'nosniff',
    'Cache-Control' => "public, max-age=#{1.hour.to_i}"
  }

  # Compress JS using a preprocessor.
  config.assets.js_compressor = nil

  # Compress CSS using a preprocessor.
  # We're already using sass and that is set to compress at compile time
  # so a second pass is not needed - the second pass was (maybe still is)
  # causing problems with GovUK frontend use of variables
  config.assets.css_compressor = nil

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = true

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Include generic and useful information about system operation, but avoid logging too much
  # information to avoid inadvertent exposure of personally identifiable information (PII).
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id, ->(_) { "PID:#{Process.pid}" }]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "school_experience_test"

  # config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  # ActionMailer::Base.deliveries array.
  # config.action_mailer.delivery_method = :test

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Raises error for missing translations.
  config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Print deprecation notices to the stderr.
  config.active_support.deprecation = :stderr

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require "syslog/logger"
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  # if ENV["RAILS_LOG_TO_STDOUT"].present?
  #  logger           = ActiveSupport::Logger.new(STDOUT)
  #  logger.formatter = config.log_formatter
  #  config.logger    = ActiveSupport::TaggedLogging.new(logger)
  # end

  # Do not dump schema after migrations.
  # config.active_record.dump_schema_after_migration = false

  # Inserts middleware to perform automatic connection switching.
  # The `database_selector` hash is used to pass options to the DatabaseSelector
  # middleware. The `delay` is used to determine how long to wait after a write
  # to send a subsequent read to the primary.
  #
  # The `database_resolver` class is used by the middleware to determine which
  # database is appropriate to use based on the time delay.
  #
  # The `database_resolver_context` class is used by the middleware to set
  # timestamps for the last write to the primary. The resolver uses the context
  # class timestamps to determine how long to wait before reading from the
  # replica.
  #
  # By default Rails will store a last write timestamp in the session. The
  # DatabaseSelector middleware is designed as such you can define your own
  # strategy for connection switching and pass that into the middleware through
  # these configuration options.
  # config.active_record.database_selector = { delay: 2.seconds }
  # config.active_record.database_resolver = ActiveRecord::Middleware::DatabaseSelector::Resolver
  # config.active_record.database_resolver_context = ActiveRecord::Middleware::DatabaseSelector::Resolver::Session

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

  # Don't actually attempt to delivery emails during tests
  config.x.notify_client = NotifyFakeClient

  config.x.default_phase = 4
  config.x.phase = 10_000
  config.x.candidates.deactivate_applications = false
  config.x.candidates.disable_applications = false
  config.x.candidates.alert_notification = nil
  config.x.google_maps_key = nil

  config.x.base_url = 'https://some-host'
  config.x.oidc_client_id = 'se-test'
  config.x.oidc_client_secret = 'abc123'
  config.x.oidc_host = 'some-oidc-host.education.gov.uk'
  config.x.oidc_services_list_url = 'https://some-oidc.provider.com/my-services'

  config.x.dfe_sign_in_api_host = 'some-signin-host.signin.education.gov.uk'

  config.x.dfe_sign_in_api_enabled = false
  config.x.dfe_sign_in_api_role_check_enabled = false
  config.x.dfe_sign_in_api_school_change_enabled = false
  config.x.dfe_sign_in_admin_service_id = '66666666-5555-aaaa-bbbb-cccccccccccc'
  config.x.dfe_sign_in_admin_role_id = '66666666-5555-4444-3333-222222222222'
  config.x.dfe_sign_in_request_organisation_url = nil

  config.x.gitis.fake_crm = true
  config.x.gitis.auth_client_id = nil
  config.x.gitis.auth_secret = nil
  config.x.gitis.auth_tenant_id = nil
  config.x.gitis.service_url = nil
  config.x.gitis.channel_creation = '0'
  config.x.gitis.country_id = SecureRandom.uuid
  config.x.gitis.privacy_policy_id = SecureRandom.uuid
  config.x.gitis.privacy_consent_id = '10'
  config.x.gitis.caching = false

  config.x.features = %i[
    subject_specific_dates
    capped_bookings
    reminders
  ]

  config.sass[:style] = :compressed if config.sass

  config.ab_threshold = Integer ENV.fetch('AB_TEST_THRESHOLD', 100)

  config.x.maintenance_mode = false

  config.after_initialize do
    Bullet.enable = true
    Bullet.raise = true
  end
end
