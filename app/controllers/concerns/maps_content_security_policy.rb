module MapsContentSecurityPolicy
  extend ActiveSupport::Concern

  included do
    content_security_policy(only: :show) do |policy| # Allow google maps
      policy.connect_src :self, 'https://www.google.com', 'https://www.google-analytics.com'
      policy.font_src :self, :data, 'https://fonts.googleapis.com/'
      policy.img_src :self, :data, "https://www.google.com", "https://maps.googleapis.com", "https://maps.gstatic.com/", "https://www.google-analytics.com"
      policy.style_src :self, "'unsafe-inline'", 'https://www.google.com', 'https://fonts.googleapis.com/'
      policy.script_src :self, :data, "'unsafe-inline'",
        "'unsafe-eval'",
        "https://www.google.com",
        "https://maps.googleapis.com",
        "https://www.googletagmanager.com",
        "https://www.google-analytics.com",
        "https://az416426.vo.msecnd.net" # needed for AppInsights
    end
  end
end
