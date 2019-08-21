module Schools
  module DFESignInAPI
    class Organisations < Client
      attr_accessor :user_uuid

      def initialize(user_uuid)
        self.user_uuid = user_uuid
      end

      def schools
        organisations
          .each
          .with_object({}) do |school, h|
            h[school.fetch('urn').to_i] = school.fetch('name')
          end
      end

      def urns
        organisations.map { |record| record.fetch('urn').to_i }
      end

    private

      def organisations
        @organisations ||= response
      end

      def organisations!
        @organisations = response
      end

      def response
        resp = Faraday.new.get(endpoint) do |req|
          req.headers['Authorization'] = "bearer #{token}"
          req.headers['Content-Type']  = 'application/json'
        end

        JSON.parse(resp.body)
      end

      def endpoint
        URI::HTTPS.build(
          host: Rails.configuration.x.dfe_sign_in_api_host,
          path: ['/users', user_uuid, 'organisations'].join('/')
        )
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
