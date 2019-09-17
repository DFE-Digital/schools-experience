if ENV['SECURE_USERNAME'].present? && ENV['SECURE_PASSWORD'].present? && !Rails.env.test?
  ApplicationController.before_action :http_basic_authenticate
  HealthchecksController.skip_before_action :http_basic_authenticate, except: :show
end
