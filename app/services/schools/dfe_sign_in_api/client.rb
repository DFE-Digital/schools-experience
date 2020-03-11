module Schools
  module DFESignInAPI
    class APIResponseError < RuntimeError; end

    class Client
      TIMEOUT_SECS = 10
      RETRY_EXCEPTIONS = [::Faraday::ConnectionFailed].freeze
      RETRY_OPTIONS = {
        max: 2,
        methods: %i{get},
        exceptions:
          ::Faraday::Request::Retry::DEFAULT_EXCEPTIONS + RETRY_EXCEPTIONS
      }.freeze

      def self.enabled?
        Rails.application.config.x.dfe_sign_in_api_enabled &&
          [
            ENV.fetch('DFE_SIGNIN_API_CLIENT', nil),
            ENV.fetch('DFE_SIGNIN_API_SECRET', nil)
          ].all?(&:present?)
      end
      delegate :enabled?, to: :class

      class ApiDisabled < RuntimeError; end
      class ApiError < RuntimeError; end
      class ApiTimeout < ApiError; end
      class ApiConnectionFailed < ApiError; end

    private

      def response
        raise ApiDisabled unless enabled?

        resp = faraday.get(endpoint) do |req|
          req.headers['Authorization'] = "bearer #{token}"
          req.headers['Content-Type']  = 'application/json'
        end

        JSON.parse(resp.body)
      rescue Faraday::TimeoutError => e
        raise ApiTimeout.new(e)
      rescue Faraday::ConnectionFailed => e
        raise ApiConnectionFailed.new(e)
      end

      def faraday
        Faraday.new do |f|
          f.use Faraday::Response::RaiseError
          f.adapter Faraday.default_adapter
          f.request :retry, RETRY_OPTIONS
        end
      end

      def token
        JWT.encode(payload, ENV.fetch('DFE_SIGNIN_API_SECRET'))
      end

      def payload
        {
          iss: ENV.fetch('DFE_SIGNIN_API_CLIENT'),
          aud: 'signin.education.gov.uk'
        }
      end
    end
  end
end
