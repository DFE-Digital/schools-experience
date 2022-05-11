require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Verifies that versions and hashed value of the package contents in the project's package.json
  config.webpacker.check_yarn_integrity = true
  # Settings specified here will take precedence over those in config/application.rb.

  # In development log more information
  config.log_level = :debug

  # In the development environment your application's code is reloaded any time
  # it changes. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Show the custom error pages.
  # Set the 'consider_all_requests_local' to false.
  # config.exceptions_app = routes

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  # config.action_mailer.raise_delivery_errors = false

  # config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise exceptions for disallowed deprecations.
  config.active_support.disallowed_deprecation = :raise

  # Tell Active Support which deprecation messages to disallow.
  config.active_support.disallowed_deprecation_warnings = []

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Raises error for missing translations.
  # config.i18n.raise_on_missing_translations = true

  # Annotate rendered view with file names.
  # config.action_view.annotate_rendered_view_with_filenames = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # Use Redis for Session and cache if REDIS_URL or REDIS_CACHE_URL is set
  config.cache_store = :redis_cache_store,
                       {
                         url: ENV['REDIS_CACHE_URL'].presence || ENV['REDIS_URL']
                       }

  config.session_store :cache_store,
    key: 'schoolex-session',
    expire_after: 1.hour # Sets explicit TTL for Session Redis keys

  config.after_initialize do
    Bullet.enable = true
    Bullet.raise = true
    Bullet.rails_logger = true
    Bullet.unused_eager_loading_enable = false
  end

  config.x.candidates.deactivate_applications = ENV['DEACTIVATE_CANDIDATES'].to_s.presence || false
  config.x.google_maps_key = ENV['GOOGLE_MAPS_KEY'].presence || Rails.application.credentials[:google_maps_key]

  # dfe signin redirects back to https, so force it
  config.force_ssl = true

  # dfe signin config, should be in credentials or env vars
  config.x.base_url = 'https://localhost:3000'
  config.x.oidc_client_id = 'schoolexperience'
  config.x.oidc_client_secret = Rails.application.credentials[:dfe_pp_signin_secret]
  config.x.oidc_host = 'pp-oidc.signin.education.gov.uk'
  config.x.dfe_sign_in_api_host = 'pp-api.signin.education.gov.uk'

  truthy_strings = %w[true 1 yes]

  config.x.dfe_sign_in_api_enabled = ENV['DFE_SIGNIN_API_ENABLED']&.in?(truthy_strings)
  config.x.dfe_sign_in_api_role_check_enabled = ENV['DFE_SIGNIN_API_ROLE_CHECK_ENABLED']&.in?(truthy_strings)
  config.x.dfe_sign_in_api_school_change_enabled = ENV['DFE_SIGNIN_API_SCHOOL_CHANGE_ENABLED']&.in?(truthy_strings)
  config.x.dfe_sign_in_request_organisation_url = "https://pp-services.signin.education.gov.uk/request-organisation/search"
  config.x.dfe_sign_in_add_service_url = "https://pp-services.signin.education.gov.uk/approvals/select-organisation?action=add-service"

  if ENV['NOTIFY_CLIENT'].present?
    Rails.application.config.x.notify_client = ENV['NOTIFY_CLIENT']
  end

  config.x.gitis.fake_crm_uuid = ENV.fetch('FAKE_CRM_UUID', nil)
  config.x.gitis.privacy_consent_id = ENV['CRM_PRIVACY_CONSENT_ID'].presence || '222750001'

  config.ab_threshold = Integer ENV.fetch('AB_TEST_THRESHOLD', 100)

  config.x.maintenance_mode = true

  config.x.git_api_token = Rails.application.credentials.git_api_token.presence
  config.x.git_api_endpoint = "https://get-into-teaching-api-dev.london.cloudapps.digital/api"
  config.x.api_client_cache_store = ActiveSupport::Cache::MemoryStore.new
end
