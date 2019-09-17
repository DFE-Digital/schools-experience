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

      def endpoint
        URI::HTTPS.build(
          host: Rails.configuration.x.dfe_sign_in_api_host,
          path: ['/users', user_uuid, 'organisations'].join('/')
        )
      end
    end
  end
end
