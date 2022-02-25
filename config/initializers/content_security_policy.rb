# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy
# For further information see the following documentation
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy

# Rails.application.config.content_security_policy do |policy|
#   # If you are using webpack-dev-server then specify webpack-dev-server host
#   policy.connect_src :self, :https, "http://localhost:3035", "ws://localhost:3035" if Rails.env.development?

#   policy.default_src :self, :https
#   policy.font_src    :self, :https, :data
#   policy.img_src     :self, :https, :data
#   policy.object_src  :none
#   policy.script_src  :self, :https
#   policy.style_src   :self, :https

#   # Specify URI for violation reports
#   # policy.report_uri "/csp-violation-report-endpoint"
# end

# If you are using UJS then enable automatic nonce generation
Rails.application.config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }

# Set the nonce only to specific directives
Rails.application.config.content_security_policy_nonce_directives = %w[script-src]

# Report CSP violations to a specified URI
# For further information see the following documentation:
# https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Security-Policy-Report-Only
# Rails.application.config.content_security_policy_report_only = true

# Allow connections to webpack-dev-server
if Rails.env.development?
  connect_src = ['https://localhost:3035', 'wss://localhost:3035']
end

Rails.application.config.content_security_policy do |policy|
  policy.default_src :self

  policy.base_uri :self
  policy.connect_src :self,
    "https://dc.services.visualstudio.com",
    "https://www.google-analytics.com",
    "https://maps.googleapis.com",
    *connect_src
  policy.frame_src :self, "https://www.googletagmanager.com/" # GTM fallback
  policy.img_src :self, "https://www.google-analytics.com"
  policy.object_src :none
  policy.script_src :self,
    "https://www.googletagmanager.com",
    "https://www.google-analytics.com",
    "https://maps.googleapis.com",
    "https://az416426.vo.msecnd.net", # needed for App Insights
    "https://code.jquery.com/jquery-3.2.1.slim.min.js", # needed for Flipper UI
    "https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js", # needed for Flipper UI
    "https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" # needed for Flipper UI
  policy.style_src :self,
    "'unsafe-inline'", # needed for Flipper UI
    "https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" # needed for Flipper UI
end
