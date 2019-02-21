class ApplicationController < ActionController::Base
protected

  def http_basic_authenticate
    authenticate_or_request_with_http_basic do |name, password|
      name == ENV['SECURE_USERNAME'] && password == ENV['SECURE_PASSWORD']
    end
  end
end
