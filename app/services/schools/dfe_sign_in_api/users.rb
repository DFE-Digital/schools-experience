module Schools
  module DFESignInAPI
    class Users < Client
      attr_accessor :organisation_ukprn

      def initialize(organisation_ukprn)
        self.organisation_ukprn = organisation_ukprn
      end

      def organisation_users
        users
          .each
          .with_object({}) do |user, h|
            h[user["sub"]] = {
              "given_name" => user["givenName"],
              "family_name" => user["familyName"],
            }
          end
      end

    private

      def users
        @response ||= response

        raise APIResponseError, "invalid response from users API" unless @response.is_a?(Hash)

        @response["users"]
      end

      def endpoint
        URI::HTTPS.build(
          host: Rails.configuration.x.dfe_sign_in_api_host,
          path: ["/organisations", organisation_ukprn, "users"].join("/")
        )
      end
    end
  end
end
