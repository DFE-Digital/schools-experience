GetIntoTeachingApiClient.configure do |config|
  config.api_key["Authorization"] = Rails.application.config.x.git_api_token.presence

  endpoint = Rails.application.config.x.git_api_endpoint.presence

  if endpoint
    parsed = URI.parse(endpoint)

    config.host = parsed.hostname
    config.base_path = parsed.path.gsub(%r{\A/api}, "")
  end

  config.cache_store = Rails.application.config.x.api_client_cache_store
end
