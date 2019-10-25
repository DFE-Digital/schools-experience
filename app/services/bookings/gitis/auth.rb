module Bookings
  module Gitis
    class Auth
      CACHE_KEY = 'gitis-auth-token'.freeze
      EXPIRY_MARGIN = 300
      AUTH_URL = "https://login.microsoftonline.com/{tenant_id}/oauth2/token".freeze
      attr_reader :service_url, :expires_at, :expires_in

      delegate :cache, to: Rails

      def initialize(client_id: nil, client_secret: nil, tenant_id: nil, service_url: nil)
        @client_id = client_id || config.auth_client_id
        @client_secret = client_secret || config.auth_secret
        @tenant_id = tenant_id || config.auth_tenant_id
        @service_url = service_url || config.service_url
      end

      def config
        Rails.application.config.x.gitis
      end

      def token(force_reload = false)
        if !force_reload && (cached_token = fetch_cached_token) && cached_token.present?
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
        @expires_in = data['expires_in'].to_i - EXPIRY_MARGIN # Don't use token right up to expiry time
        @expires_at = Time.zone.now + @expires_in
        @access_token = data['access_token']
      end

      def fetch_cached_token
        cache.fetch(CACHE_KEY)
      end
    end
  end
end
