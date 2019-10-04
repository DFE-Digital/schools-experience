if ENV['CANONICAL_DOMAIN'].present? || Rails.env.test? || Rails.env.servertest?
  Rails.application.config.middleware.insert(0, Rack::Rewrite) do
    proto = Rails.application.config.force_ssl ? "https" : "http"

    # If request via old domain pointing directly to Rails app
    r302 %r{.*},
      lambda { |match, rack_env| "#{proto}://#{ENV['CANONICAL_DOMAIN']}/pages/migration" },
      if: Proc.new { |rack_env|
        ENV['CANONICAL_DOMAIN'].present? &&
          ENV['OLD_SEP_DOMAINS'].present? &&
          rack_env['HTTP_HOST'].in?(ENV['OLD_SEP_DOMAINS'].split(',').compact)
      }

    r302 %r{(.*)},
      lambda { |match, rack_env| "#{proto}://#{ENV['CANONICAL_DOMAIN']}#{match[1]}" },
      if: Proc.new { |rack_env|
        ENV['CANONICAL_DOMAIN'].present? &&
          rack_env['HTTP_HOST'] != ENV['CANONICAL_DOMAIN'] &&
          !rack_env['PATH_INFO'].in?(%w(/healthcheck.txt /deployment.txt))
      }
  end
end
