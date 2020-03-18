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

      def self.role_check_enabled?
        enabled? && Feature.active?(:rolecheck) &&
          [
            ENV.fetch('DFE_SIGNIN_SCHOOL_EXPERIENCE_ADMIN_SERVICE_ID', nil),
            ENV.fetch('DFE_SIGNIN_SCHOOL_EXPERIENCE_ADMIN_ROLE_ID', nil)
          ].all?(&:present?)
      end
      delegate :role_check_enabled?, to: :class

      class ApiDisabled < RuntimeError; end

    private

      def response
        raise ApiDisabled unless enabled?

        resp = faraday.get(endpoint) do |req|
          req.headers['Authorization'] = "bearer #{token}"
          req.headers['Content-Type']  = 'application/json'
        end

        JSON.parse(resp.body)
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
