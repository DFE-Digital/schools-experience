GetIntoTeachingApiClient.configure do |config|
  config.api_key["apiKey"] = Rails.application.config.x.git_api_token.presence

  endpoint = Rails.application.config.x.git_api_endpoint.presence

  if endpoint
    parsed = URI.parse(endpoint)

    config.host = parsed.hostname
    config.base_path = parsed.path.gsub(%r{\A/api}, "")
  end

  config.server_index = nil
  config.api_key_prefix["apiKey"] = "Bearer"
  config.scheme = "https"
  config.cache_store = Rails.application.config.x.api_client_cache_store
end
