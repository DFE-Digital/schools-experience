if ENV['SECURE_USERNAME'].present? && ENV['SECURE_PASSWORD'].present?
  ApplicationController.before_action :http_basic_authenticate
  PagesController.skip_before_action :http_basic_authenticate, only: :healthcheck
end
