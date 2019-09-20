module Schools
  module DFESignInAPI
    class NoOrganisationError < RuntimeError; end

    class Roles < Client
      attr_accessor :user_uuid, :urn

      def initialize(user_uuid, urn)
        self.user_uuid = user_uuid
        self.urn       = urn
      end

      def has_school_experience_role?
        roles.any? { |role| role['id'] == ENV.fetch('SCHOOL_EXPERIENCE_ADMIN_ROLE_ID') }
      end

    private

      def roles
        @response ||= response

        unless @response.is_a?(Hash) && @response.has_key?('roles')
          fail APIResponseError, 'invalid response from roles API'
        end

        @response.fetch('roles')
      end

      def organisation_uuid
        Schools::DFESignInAPI::Organisations
          .new(user_uuid)
          .id(urn)
          .tap do |org_id|
            fail NoOrganisationError, "No organisation ID found for user #{user_uuid}" unless org_id.present?
          end
      end

      def endpoint
        URI::HTTPS.build(
          host: Rails.configuration.x.dfe_sign_in_api_host,
          path: [
            '/services',     ENV.fetch('SCHOOL_EXPERIENCE_ADMIN_SERVICE_ID'),
            'organisations', organisation_uuid,
            'users',         user_uuid
          ].join('/')
        )
      end
    end
  end
end
