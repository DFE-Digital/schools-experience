class ApplicationController < ActionController::Base
  rescue_from ActionController::InvalidAuthenticityToken, with: :session_expired

  before_action :http_basic_authenticate, if: :requires_basic_auth?

  CRAWLABLE_PATHS = %w[/ /candidates /robots.txt /sitemap.xml].freeze
  before_action :add_x_robots_tag

protected

  def requires_basic_auth?
    ENV['SECURE_USERNAME'].present? && ENV['SECURE_PASSWORD'].present? && !Rails.env.test?
  end

  def add_x_robots_tag(set_to_all: false)
    headers["X-Robots-Tag"] = if set_to_all || request.path.in?(CRAWLABLE_PATHS)
                                "all"
                              else
                                "none"
                              end
  end

  def http_basic_authenticate
    authenticate_or_request_with_http_basic do |name, password|
      name == ENV['SECURE_USERNAME'] && password == ENV['SECURE_PASSWORD']
    end
  end

  def session_expired(exception)
    Sentry.capture_exception(exception)

    render 'shared/session_expired'
  end

  def cookie_preferences
    @cookie_preferences ||= \
      CookiePreference.from_cookie cookies[CookiePreference.cookie_key]
  end
  helper_method :cookie_preferences

  def show_candidate_alert_notification?
    false
  end
  helper_method :show_candidate_alert_notification?
end
