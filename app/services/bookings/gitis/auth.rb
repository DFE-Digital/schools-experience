require 'apimock/gitis_crm'

module Bookings
  module Gitis
    class Auth
      AUTH_URL = "https://login.microsoftonline.com/{tenant_id}/oauth2/token".freeze
      attr_reader :service_url, :expires_at

      def initialize(client_id: nil, client_secret: nil, tenant_id: nil, service_url: nil)
        @client_id = client_id || ENV.fech('CRM_CLIENT_ID')
        @client_secret = client_secret || ENV.fetch('CRM_CLIENT_SECRET')
        @tenant_id = tenant_id || ENV.fetch('CRM_AUTH_TENANT_ID')
        @service_url = service_url || ENV.fetch('CRM_SERVICE_URL')
      end

      def token
        retrieve_token
      end

      class UnableToRetrieveToken < RuntimeError; end
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
        raise UnableToRetrieveToken
      end

      def parse_successful_response(response)
        data = JSON.parse(response.body)
        @expires_at = Time.zone.now + data['expires_in'].to_i
        @access_token = data['access_token']
      end
    end
  end
end
