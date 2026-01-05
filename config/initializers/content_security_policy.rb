# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

# Rails.application.configure do
#   config.content_security_policy do |policy|
#     policy.default_src :self, :https
#     policy.font_src    :self, :https, :data
#     policy.img_src     :self, :https, :data
#     policy.object_src  :none
#     policy.script_src  :self, :https
#     policy.style_src   :self, :https
#     # Specify URI for violation reports
#     # policy.report_uri "/csp-violation-report-endpoint"
#   end
#
#   # Generate session nonces for permitted importmap, inline scripts, and inline styles.
#   config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
#   config.content_security_policy_nonce_directives = %w(script-src style-src)
#
#   # Report violations without enforcing the policy.
#   # config.content_security_policy_report_only = true
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
                     "googleapis.com",
                     *connect_src
  policy.frame_src :self, "https://www.googletagmanager.com/" # GTM fallback
  policy.img_src :self, "https://www.google-analytics.com"
  policy.object_src :none
  policy.script_src :self,
                    "https://www.googletagmanager.com",
                    "https://www.google-analytics.com",
                    "https://maps.googleapis.com",
                    "googleapis.com",
                    "https://code.jquery.com/jquery-3.2.1.slim.min.js", # needed for Flipper UI
                    "https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.12.9/umd/popper.min.js", # needed for Flipper UI
                    "https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/js/bootstrap.min.js" # needed for Flipper UI
  policy.style_src :self,
                   "'unsafe-inline'", # needed for Flipper UI
                   "https://maxcdn.bootstrapcdn.com/bootstrap/4.0.0/css/bootstrap.min.css" # needed for Flipper UI
end
