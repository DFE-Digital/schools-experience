module Schools
  module DFESignInAPI
    class APIResponseError < RuntimeError; end

    class Client
      def self.enabled?
        [
          ENV['DFE_SIGNIN_API_CLIENT'],
          ENV['DFE_SIGNIN_API_SECRET']
        ].map(&:presence).all?
      end
      delegate :enabled?, to: :class

    private

      def response
        return [] unless enabled?

        resp = faraday.get(endpoint) do |req|
          req.headers['Authorization'] = "bearer #{token}"
          req.headers['Content-Type']  = 'application/json'
        end

        JSON.parse(resp.body)
      end

      def faraday
        Faraday.new do |f|
          f.use(Faraday::Response::RaiseError)
          f.adapter(Faraday.default_adapter)
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
