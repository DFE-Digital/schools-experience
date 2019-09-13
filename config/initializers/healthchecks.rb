Rails.application.config.x.healthchecks.username =
  ENV['DEPLOYMENT_USERNAME'].presence || SecureRandom.uuid

Rails.application.config.x.healthchecks.password =
  ENV['DEPLOYMENT_PASSWORD'].presence || SecureRandom.uuid
