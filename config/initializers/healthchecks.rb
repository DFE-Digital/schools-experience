Rails.application.config.x.healthchecks.username =
  ENV['VERSION_USERNAME'].presence || SecureRandom.uuid

Rails.application.config.x.healthchecks.password =
  ENV['VERSION_PASSWORD'].presence || SecureRandom.uuid
