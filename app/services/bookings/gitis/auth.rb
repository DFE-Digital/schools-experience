module Bookings
  module Gitis
    class Auth
      prepend FakeAuth if Rails.application.config.x.gitis.fake_crm

      CACHE_KEY = 'gitis-auth-token'.freeze
      AUTH_URL = "https://login.microsoftonline.com/{tenant_id}/oauth2/token".freeze
      attr_reader :service_url, :expires_at, :expires_in

      delegate :cache, to: Rails

      def initialize(client_id: nil, client_secret: nil, tenant_id: nil, service_url: nil)
        @client_id = client_id || ENV.fetch('CRM_CLIENT_ID')
        @client_secret = client_secret || ENV.fetch('CRM_CLIENT_SECRET')
        @tenant_id = tenant_id || ENV.fetch('CRM_AUTH_TENANT_ID')
        @service_url = service_url || ENV.fetch('CRM_SERVICE_URL')
      end

      def token(force_reload = false)
        if !force_reload && (cached_token = fetch_cached_token)
          cached_token
        elsif (new_token = retrieve_token)
          cache.write(CACHE_KEY, new_token, expires_in: expires_in)
          new_token
        end
      end

      class UnableToRetrieveToken < RuntimeError
        def initialize(code, body)
          msg = "Response Code: #{code}\n#{body}"
          super(msg)
        end
      end

    private

      def params
        {
          grant_type: 'client_credentials',
          scope: '',
          client_id: @client_id,
          client_secret: @client_secret,
          resource: service_url
        }
      end

      def auth_url
        Addressable::Template.new(AUTH_URL).expand(tenant_id: @tenant_id).to_s
      end

      def retrieve_token
        response = Faraday.post(auth_url) do |request|
          request.headers['Content-Type'] = 'application/x-www-form-urlencoded'
          request.headers['Accept'] = 'application/json'
          request.body = params.to_query
        end

        if response.status != 200
          store_failed_response response
        else
          parse_successful_response response
        end
      end

      def store_failed_response(response)
        @response_status = response.status
        @response_body = response.body
        raise UnableToRetrieveToken.new(@response_status, @response_body)
      end

      def parse_successful_response(response)
        data = JSON.parse(response.body)
        @expires_in = data['expires_in'].to_i
        @expires_at = Time.zone.now + @expires_in
        @access_token = data['access_token']
      end

      def fetch_cached_token
        cache.fetch(CACHE_KEY)
      end
    end
  end
end
