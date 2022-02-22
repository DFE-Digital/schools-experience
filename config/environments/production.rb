require "active_support/core_ext/integer/time"

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

  # Set the exceptions application invoked by the ShowException middleware
  # when an exception happens.
  config.exceptions_app = routes

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.public_file_server.headers = {
    'X-Content-Type-Options' => 'nosniff'
  }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = false

  # Logging
  config.log_level = :info
  config.rails_semantic_logger.format = :json
  config.semantic_logger.backtrace_level = :error
  config.rails_semantic_logger.add_file_appender = false
  config.active_record.logger = nil # Don't log SQL in production
  config.active_record.dump_schema_after_migration = false # Do not dump schema after migrations.
  config.semantic_logger.add_appender(io: $stdout, level: config.log_level, formatter: config.rails_semantic_logger.format)

  config.logger = ActiveSupport::Logger.new($stdout)

  # Inserts middleware to perform automatic connection switching.

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id, ->(_) { "PID:#{Process.pid}" }]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment).
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "school_experience_production"

  # config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Log disallowed deprecations.
  config.active_support.disallowed_deprecation = :log

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Use a different logger for distributed setups.
  # require "syslog/logger"
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

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

  # Use Redis for Session and cache if REDIS_URL or REDIS_CACHE_URL is set
  config.cache_store = :redis_cache_store,
                       {
                         url: ENV['REDIS_CACHE_URL'].presence || ENV['REDIS_URL'].presence,
                         reconnect_attempts: 1,
                         tcp_keepalive: 60,
                         error_handler: lambda do |method:, returning:, exception:|
                                          Sentry.capture_exception(exception)
                                        end
                       }

  config.session_store :cache_store,
    key: 'schoolex-session',
    expire_after: 1.hour # Sets explicit TTL for Session Redis keys

  config.active_job.queue_adapter = :delayed_job

  Rails.application.routes.default_url_options = { protocol: 'https' }

  config.x.candidates.deactivate_applications = ENV['DEACTIVATE_CANDIDATES'].to_s.presence || false
  config.x.google_maps_key = ENV['GOOGLE_MAPS_KEY'].presence || Rails.application.credentials[:google_maps_key]

  config.x.base_url = ENV.fetch('DFE_SIGNIN_BASE_URL') { 'https://schoolexperience.education.gov.uk' }
  config.x.oidc_client_id = ENV.fetch('DFE_SIGNIN_CLIENT_ID') { 'schoolexperience' }
  config.x.oidc_client_secret = ENV.fetch('DFE_SIGNIN_SECRET') do
    msg = "DFE_SIGNIN_SECRET has not been set"
    config.logger ? config.logger.warn(msg) : Rails.logger.warn(msg)
    ''
  end
  config.x.oidc_host = ENV.fetch('DFE_SIGNIN_HOST') { 'pp-oidc.signin.education.gov.uk' }

  config.x.dfe_sign_in_api_host = ENV.fetch('DFE_SIGNIN_API_ENDPOINT') do
    'api.signin.education.gov.uk'
  end

  truthy_strings = %w[true 1 yes]

  config.x.dfe_sign_in_api_enabled = ENV['DFE_SIGNIN_API_ENABLED']&.in?(truthy_strings)
  config.x.dfe_sign_in_api_role_check_enabled = ENV['DFE_SIGNIN_API_ROLE_CHECK_ENABLED']&.in?(truthy_strings)
  config.x.dfe_sign_in_api_school_change_enabled = ENV['DFE_SIGNIN_API_SCHOOL_CHANGE_ENABLED']&.in?(truthy_strings)
  config.x.dfe_sign_in_request_organisation_url = "https://services.signin.education.gov.uk/request-organisation/search"
  config.x.dfe_sign_in_add_service_url = "https://services.signin.education.gov.uk/approvals/select-organisation?action=add-service"

  config.x.gitis.privacy_consent_id = ENV['CRM_PRIVACY_CONSENT_ID'].presence || '222750001'

  config.ab_threshold = Integer ENV.fetch('AB_TEST_THRESHOLD', 70)

  config.x.maintenance_mode = %w[1 yes true].include?(ENV['MAINTENANCE_MODE'].to_s)

  config.x.git_api_token = ENV['GIT_API_TOKEN']
  config.x.api_client_cache_store = ActiveSupport::Cache::RedisCacheStore.new(namespace: "GIT-API-HTTP")
  config.x.git_api_endpoint = "https://get-into-teaching-api-prod.london.cloudapps.digital/api"
end
