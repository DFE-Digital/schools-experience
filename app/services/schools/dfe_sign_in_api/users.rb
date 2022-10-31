module Schools
  module DFESignInAPI
    class Users < Client
      attr_accessor :ukprn

      def initialize(ukprn)
        self.ukprn = ukprn
      end

      def school_users
        users
      end

    private

      def users
        @response ||= response

        raise APIResponseError, 'invalid response from users API' unless @response.is_a?(Hash)

        @response["users"]
      end

      def endpoint
        URI::HTTPS.build(
          host: Rails.configuration.x.dfe_sign_in_api_host,
          path: ['/organisations', ukprn, 'users'].join('/')
        )
      end
    end
  end
end
