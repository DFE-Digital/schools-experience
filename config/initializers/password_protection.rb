if ENV['SECURE_USERNAME'].present? && ENV['SECURE_PASSWORD'].present?
  ApplicationController.http_basic_authenticate_with(
    name: ENV['SECURE_USERNAME'],
    password: ENV['SECURE_PASSWORD']
  )
end
