if ENV['CANONICAL_DOMAIN'].present? || Rails.env.test? || Rails.env.servertest?
  Rails.application.config.middleware.insert(0, Rack::Rewrite) do
    proto = Rails.application.config.force_ssl ? "https" : "http"

    r302 %r{(.*)},
      ->(match, _rack_env) { "#{proto}://#{ENV['CANONICAL_DOMAIN']}#{match[1]}" },
      if: proc { |rack_env|
        ENV['CANONICAL_DOMAIN'].present? &&
          rack_env['HTTP_HOST'] != ENV['CANONICAL_DOMAIN'] &&
          !rack_env['PATH_INFO'].match?(%r{/(healthcheck|deployment|healthchecks/[a-z]+)\.txt})
      }
  end
end
