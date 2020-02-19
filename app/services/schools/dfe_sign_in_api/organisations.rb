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

      def uuids
        organisations.each.with_object({}) do |record, uuidmap|
          uuidmap[record['id']] = record['urn']
        end
      end

      def id(urn)
        organisations
          .find { |org| org['urn'].to_i == urn }
          &.fetch('id')
      end

    private

      def organisations
        @response ||= response

        fail APIResponseError, 'invalid response from organisations API' unless @response.is_a?(Array)

        @response
      end

      def endpoint
        URI::HTTPS.build(
          host: Rails.configuration.x.dfe_sign_in_api_host,
          path: ['/users', user_uuid, 'organisations'].join('/')
        )
      end
    end
  end
end
