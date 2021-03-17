Sentry.init do |config|
  config.excluded_exceptions -= ['ActionController::InvalidAuthenticityToken']
end
