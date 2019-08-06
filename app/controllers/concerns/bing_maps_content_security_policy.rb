module BingMapsContentSecurityPolicy
  extend ActiveSupport::Concern

  included do
    content_security_policy(only: :show) do |policy| # Allow bing maps
      policy.connect_src :self, 'https://www.bing.com', "https://*.visualstudio.com"
      policy.font_src :self, :data
      policy.img_src :self, :data, 'https://www.bing.com', 'https://*.virtualearth.net', "https://www.google-analytics.com"
      policy.style_src :self, "'unsafe-inline'", 'https://www.bing.com'
      policy.script_src :self, :data, "'unsafe-inline'",
        "'unsafe-eval'",
        'https://www.bing.com',
        'https://*.virtualearth.net',
        "https://www.googletagmanager.com",
        "https://www.google-analytics.com",
        "https://*.vo.msecnd.net"
    end
  end
end
