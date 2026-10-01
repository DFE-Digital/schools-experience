module Schools
  module DFESignInAPI
    # Probes the public, unauthenticated DfE Sign In healthcheck endpoint.
    #
    # Unlike the other DFESignInAPI services this does not subclass Client: the
    # endpoint needs no JWT or client/secret, and a healthcheck wants a short,
    # bounded timeout rather than Client's longer timeout and retries.
    #
    # It fails closed - any error or unexpected response is reported as "not up".
    # When the integration is disabled there is nothing to probe, so it reports
    # healthy (true) rather than failing the overall healthcheck.
    class Healthcheck
      TIMEOUT_SECS = 5
      HEALTHY_STATUS = 'up'.freeze

      def up?
        return true unless enabled?

        JSON.parse(response.body)['status'] == HEALTHY_STATUS
      rescue Faraday::Error, JSON::ParserError
        false
      end

    private

      def enabled?
        Rails.application.config.x.dfe_sign_in_api_enabled
      end

      def response
        faraday.get(endpoint)
      end

      def faraday
        Faraday.new(request: { timeout: TIMEOUT_SECS, open_timeout: TIMEOUT_SECS }) do |f|
          f.use Faraday::Response::RaiseError
          f.adapter Faraday.default_adapter
        end
      end

      def endpoint
        URI::HTTPS.build(
          host: Rails.application.config.x.dfe_sign_in_help_host,
          path: '/healthcheck'
        )
      end
    end
  end
end
