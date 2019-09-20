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
        Rails.logger.debug("ROLES: checking #{roles.size} roles for 'School Experience Administrator'")
        exists = roles.any? { |role| role['id'] == Rails.application.config.x.dfe_sign_in_admin_role_id }

        Rails.logger.debug("ROLES: found - #{exists}")
        exists
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
            '/services',     Rails.application.config.x.dfe_sign_in_admin_service_id,
            'organisations', organisation_uuid,
            'users',         user_uuid
          ].join('/')
        )
      end
    end
  end
end
