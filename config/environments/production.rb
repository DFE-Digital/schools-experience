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

  # Ensures that a master key has been made available in either ENV["RAILS_MASTER_KEY"]
  # or in config/master.key. This key is used to decrypt credentials (and other encrypted files).
  # config.require_master_key = true

  # Disable serving static files from the `/public` folder by default since
  # Apache or NGINX already handles this.
  config.public_file_server.enabled = ENV['RAILS_SERVE_STATIC_FILES'].present?
  config.public_file_server.headers = {
    'X-Content-Type-Options' => 'nosniff'
  }

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  config.assets.css_compressor = nil

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # `config.assets.precompile` and `config.assets.version` have moved to config/initializers/assets.rb

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = 'http://assets.example.com'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = 'X-Sendfile' # for Apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for NGINX

  # Store uploaded files on the local file system (see config/storage.yml for options)
#  config.active_storage.service = :local

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Use the lowest log level to ensure availability of diagnostic information
  # when problems arise.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  config.log_tags = [:request_id, lambda { |_| "PID:#{Process.pid}" }]

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Use a real queuing backend for Active Job (and separate queues per environment)
  # config.active_job.queue_adapter     = :resque
  # config.active_job.queue_name_prefix = "school_experience_#{Rails.env}"

#  config.action_mailer.perform_caching = false

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = [I18n.default_locale]

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  # Use a different logger for distributed setups.
  # require 'syslog/logger'
  # config.logger = ActiveSupport::TaggedLogging.new(Syslog::Logger.new 'app-name')

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Use Redis for Session and cache if REDIS_URL or REDIS_CACHE_URL is set
  config.cache_store = :redis_cache_store, {
    url: ENV['REDIS_CACHE_URL'].presence || ENV['REDIS_URL'].presence,
    reconnect_attempts: 1,
    tcp_keepalive: 60,
    error_handler: ->(_method:, returning:, exception:) do
      ExceptionNotifier.notify_exception(
        exception,
        data: {
          returning: returning.inspect
        }
      )

      Raven.capture_exception(exception)
    end
  }

  config.session_store :cache_store,
    key: 'schoolex-session',
    expire_after: 1.hour # Sets explicit TTL for Session Redis keys

  config.active_job.queue_adapter = :delayed_job

  config.force_ssl = true

  Rails.application.routes.default_url_options = { protocol: 'https' }

  config.x.default_phase = 4
  config.x.phase = Integer(ENV['PHASE'].presence || config.x.default_phase)
  config.x.base_url = ENV.fetch('DFE_SIGNIN_BASE_URL') { 'https://schoolexperience.education.gov.uk' }
  config.x.oidc_client_id = ENV.fetch('DFE_SIGNIN_CLIENT_ID') { 'schoolexperience' }
  config.x.oidc_client_secret = ENV.fetch('DFE_SIGNIN_SECRET') do
    msg = "DFE_SIGNIN_SECRET has not been set"
    config.logger ? config.logger.warn(msg) : puts(msg)
    ''
  end
  config.x.oidc_host = ENV.fetch('DFE_SIGNIN_HOST') { 'pp-oidc.signin.education.gov.uk' }
  config.x.oidc_services_list_url = ENV.fetch('DFE_SERVICES_LIST_URL') do
    'https://services.signin.education.gov.uk/my-services'
  end

  config.x.dfe_sign_in_api_host = ENV.fetch('DFE_SIGNIN_API_ENDPOINT') do
    'api.signin.education.gov.uk'
  end

  truthy_strings = %w(true 1 yes)

  config.x.dfe_sign_in_api_enabled = ENV['DFE_SIGNIN_API_ENABLED']&.in?(truthy_strings)
  config.x.dfe_sign_in_api_school_change_enabled = ENV['DFE_SIGNIN_API_SCHOOL_CHANGE_ENABLED']&.in?(truthy_strings)
  config.x.dfe_sign_in_request_organisation_url = ENV['DFE_SIGNIN_REQUEST_ORGANISATION_URL'].presence

  config.x.gitis.fake_crm = truthy_strings.include?(ENV['FAKE_CRM'].to_s)
  if ENV['CRM_CLIENT_ID'].present?
    config.x.gitis.auth_client_id = ENV.fetch('CRM_CLIENT_ID')
    config.x.gitis.auth_secret = ENV.fetch('CRM_CLIENT_SECRET')
    config.x.gitis.auth_tenant_id = ENV.fetch('CRM_AUTH_TENANT_ID')
    config.x.gitis.service_url = ENV.fetch('CRM_SERVICE_URL')
    config.x.gitis.channel_creation = ENV.fetch('CRM_CHANNEL_CREATION')
    config.x.gitis.country_id = ENV.fetch('CRM_COUNTRY_ID')
    config.x.gitis.privacy_policy_id = ENV['CRM_PRIVACY_POLICY_ID'].presence || '0a203956-e935-ea11-a813-000d3a44a8e9'
    config.x.gitis.privacy_consent_id = ENV['CRM_PRIVACY_CONSENT_ID'].presence || '222750001'
    config.x.gitis.caching = truthy_strings.include?(ENV['CRM_CACHING'].to_s)
  end

  config.x.features = %i(subject_specific_dates)

  config.sass[:style] = :compressed if config.sass

  config.ab_threshold = Integer ENV.fetch('AB_TEST_THRESHOLD', 70)

  config.x.maintenance_mode = %w{1 yes true}.include?(ENV['MAINTENANCE_MODE'].to_s)
end
