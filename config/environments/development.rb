Rails.application.configure do
  # Verifies that versions and hashed value of the package contents in the project's package.json
  config.webpacker.check_yarn_integrity = true
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
#  config.active_storage.service = :local

  # Don't care if the mailer can't send.
#  config.action_mailer.raise_delivery_errors = false

#  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.sass.inline_source_maps = true

  # Use Redis for Session and cache if REDIS_URL or REDIS_CACHE_URL is set
  config.cache_store = :redis_cache_store, {
    url: ENV['REDIS_CACHE_URL'].presence || ENV['REDIS_URL']
  }

  config.session_store :cache_store,
    key: 'schoolex-session',
    expire_after: 1.hour # Sets explicit TTL for Session Redis keys

  config.after_initialize do
    Bullet.enable = true
    Bullet.raise = true
    Bullet.rails_logger = true
  end

  config.x.phase = Integer(ENV.fetch('PHASE') { 10000 })
  config.x.features = %i(
    subject_specific_dates
    capped_bookings
  )

  # dfe signin redirects back to https, so force it
  config.force_ssl = true

  # dfe signin config, should be in credentials or env vars
  config.x.base_url = 'https://localhost:3000'
  config.x.oidc_client_id = 'schoolexperience'
  config.x.oidc_client_secret = Rails.application.credentials.dig(:dfe_pp_signin_secret)
  config.x.oidc_host = 'pp-oidc.signin.education.gov.uk'
  config.x.oidc_services_list_url = 'https://pp-services.signin.education.gov.uk/my-services'
  config.x.dfe_sign_in_api_host = 'pp-api.signin.education.gov.uk'

  truthy_strings = %w(true 1 yes)

  config.x.dfe_sign_in_api_enabled = ENV['DFE_SIGNIN_API_ENABLED']&.in?(truthy_strings)
  config.x.dfe_sign_in_api_role_check_enabled = ENV['DFE_SIGNIN_API_ROLE_CHECK_ENABLED']&.in?(truthy_strings)
  config.x.dfe_sign_in_api_school_change_enabled = ENV['DFE_SIGNIN_API_SCHOOL_CHANGE_ENABLED']&.in?(truthy_strings)

  if ENV['NOTIFY_CLIENT'] && ENV['NOTIFY_CLIENT'] != ''
    Rails.application.config.x.notify_client = ENV['NOTIFY_CLIENT'].constantize
  end

  config.x.gitis.fake_crm = truthy_strings.include?(String(ENV.fetch('FAKE_CRM') { true }))
  config.x.gitis.fake_crm_uuid = ENV.fetch('FAKE_CRM_UUID', nil)
  config.x.gitis.auth_client_id = ENV.fetch('CRM_CLIENT_ID', 'notset')
  config.x.gitis.auth_secret = ENV.fetch('CRM_CLIENT_SECRET', 'notset')
  config.x.gitis.auth_tenant_id = ENV.fetch('CRM_AUTH_TENANT_ID', 'notset')
  config.x.gitis.service_url = ENV.fetch('CRM_SERVICE_URL', 'notset')
  config.x.gitis.channel_creation = ENV.fetch('CRM_CHANNEL_CREATION', '0')
  config.x.gitis.country_id = ENV.fetch('CRM_COUNTRY_ID', SecureRandom.uuid)
  config.x.gitis.privacy_policy_id = ENV['CRM_PRIVACY_POLICY_ID'].presence || 'd1adf2ad-e7c4-e911-a981-000d3a206976'
  config.x.gitis.privacy_consent_id = ENV['CRM_PRIVACY_CONSENT_ID'].presence || '222750001'

  config.ab_threshold = Integer ENV.fetch('AB_TEST_THRESHOLD', 100)

  config.x.maintenance_mode = %w{1 yes true}.include?(ENV['MAINTENANCE_MODE'].to_s)
end
