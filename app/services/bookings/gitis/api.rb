module Bookings::Gitis
  class API
    ENDPOINT = '/api/data/v9.1'.freeze
    TIMEOUT_SECS = 25
    RETRY_EXCEPTIONS = [::Faraday::ConnectionFailed].freeze
    RETRY_OPTIONS = {
      max: 2,
      methods: %i[get],
      exceptions: (
        ::Faraday::Request::Retry::DEFAULT_EXCEPTIONS + RETRY_EXCEPTIONS
      ).freeze
    }.freeze

    attr_reader :endpoint_url, :access_token

    def initialize(token, service_url: nil, endpoint: nil)
      @access_token = token
      @service_url = service_url || Rails.application.config.x.gitis.service_url
      @endpoint = endpoint || ENDPOINT
      @endpoint_url = "#{@service_url}#{@endpoint}"
    end

    def get(url, params = {}, headers = {})
      validate_url! url

      response = connection.get do |req|
        req.url url
        req.headers = get_headers.merge(headers.stringify_keys)
        req.options.timeout = TIMEOUT_SECS
        req.params = params if params.any?
      end

      parse_response response
    rescue Faraday::ConnectionFailed
      raise ConnectionFailed.new(url)
    end

    def post(url, params, headers = {})
      validate_url! url

      response = connection.post do |req|
        req.url url
        req.headers = post_headers.merge(headers.stringify_keys)
        req.body = params.to_json
      end

      parse_response response
    end

    def patch(url, params, headers = {})
      validate_url! url

      response = connection.patch do |req|
        req.url url
        req.headers = post_headers.merge(headers.stringify_keys)
        req.body = params.to_json
      end

      parse_response response
    end

    class UnsupportedAbsoluteUrlError < RuntimeError; end
    class ConnectionFailed < RuntimeError
      def initialize(url)
        super "Connection Failed: #{url}"
      end
    end

    class BadResponseError < RuntimeError
      def initialize(resp)
        if resp.headers['content-type'].to_s.match?(%r{application/json})
          @data = JSON.parse(resp.body)
          @error = @data.dig('error', 'message')
        end

        super "#{resp.status}: #{resp&.env&.url}: #{@error.presence || resp.body}"
      end
    end

    class UnknownUrlError < BadResponseError; end
    class AccessDeniedError < BadResponseError; end

  private

    def connection
      Faraday.new(endpoint_url) do |f|
        f.request(:retry, RETRY_OPTIONS)
        f.adapter(Faraday.default_adapter)
      end
    end

    def get_headers
      {
        'Accept' => 'application/json',
        'Authorization' => "Bearer #{access_token}",
        'OData-MaxVersion' => '4.0',
        'OData-Version' => '4.0'
      }
    end

    def post_headers
      {
        'Accept' => 'application/json',
        'Authorization' => "Bearer #{access_token}",
        'Content-Type' => 'application/json',
        'OData-MaxVersion' => '4.0',
        'OData-Version' => '4.0'
      }
    end

    # don't allow absolute paths since they don't combine with the endpoint
    def validate_url!(url)
      if url.to_s.starts_with? '/'
        fail UnsupportedAbsoluteUrlError
      end

      true
    end

    def parse_response(resp)
      case resp.status
      when 200
        if resp.headers['content-type'].to_s.match?(%r{application/json})
          JSON.parse(resp.body)
        else
          resp.body
        end
      when 201
        parse_entity_id(resp.headers['odata-entityid']) || resp.body
      when 204
        parse_entity_id(resp.headers['odata-entityid']) || true
      when 401
        raise AccessDeniedError.new(resp)
      when 404
        raise UnknownUrlError.new(resp)
      else
        raise BadResponseError.new(resp)
      end
    end

    def parse_entity_id(entity_id)
      entity_id&.gsub(%r{\A#{endpoint_url}\/}, '')
    end
  end
end
