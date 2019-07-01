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

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = :uglifier
  # config.assets.css_compressor = :sass

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
    error_handler: -> (method:, returning:, exception:) do
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
    expire_after: 24.hours # Sets explicit TTL for Session Redis keys

  config.active_job.queue_adapter = :delayed_job

  config.force_ssl = true

  Rails.application.routes.default_url_options = { protocol: 'https' }

  config.x.default_phase = 2
  config.x.phase = Integer(ENV['PHASE'].presence || (ENV['PHASE_TWO'].present? && 2) || config.x.default_phase)

  if config.x.phase >= 2
    config.x.base_url = ENV.fetch('DFE_SIGNIN_BASE_URL') { 'https://schoolexperience.education.gov.uk' }
    config.x.oidc_client_id = ENV.fetch('DFE_SIGNIN_CLIENT_ID') { 'schoolexperience' }
    config.x.oidc_client_secret = ENV.fetch('DFE_SIGNIN_SECRET') do
      msg = "DFE_SIGNIN_SECRET has not been set"
      config.logger ? config.logger.warn(msg) : puts(msg)
      ''
    end
    config.x.oidc_host = ENV.fetch('DFE_SIGNIN_HOST') { 'pp-oidc.signin.education.gov.uk' }
  end

  config.x.fake_crm = ['true', '1', 'yes'].include?(ENV['FAKE_CRM'].to_s)

  config.x.features = []
end
