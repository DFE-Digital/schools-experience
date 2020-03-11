Rack::OAuth2.http_config do |client|
  client.receive_timeout = Schools::DFESignInAPI::Client::TIMEOUT_SECS
end
