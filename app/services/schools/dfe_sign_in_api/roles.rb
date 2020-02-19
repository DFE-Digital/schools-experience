module Schools
  module DFESignInAPI
    class NoOrganisationError < RuntimeError; end

    class Roles < Client
      attr_accessor :user_uuid, :organisation_uuid

      class << self
        def service_id
          ENV.fetch('DFE_SIGNIN_SCHOOL_EXPERIENCE_ADMIN_SERVICE_ID')
        end

        def role_id
          ENV.fetch('DFE_SIGNIN_SCHOOL_EXPERIENCE_ADMIN_ROLE_ID')
        end
      end

      def initialize(user_uuid, organisation_uuid)
        self.user_uuid          = user_uuid
        self.organisation_uuid  = organisation_uuid
      end

      def has_school_experience_role?
        roles.any? { |role| role['id'] == self.class.role_id }
      end

    private

      def roles
        @response ||= response

        unless @response.is_a?(Hash) && @response.has_key?('roles')
          fail APIResponseError, 'invalid response from roles API'
        end

        @response.fetch('roles')
      end

      def response
        super
      rescue Faraday::ResourceNotFound
        fail NoOrganisationError, "No organisation ID found for user #{user_uuid}"
      end

      def endpoint
        URI::HTTPS.build(
          host: Rails.configuration.x.dfe_sign_in_api_host,
          path: [
            '/services',     self.class.service_id,
            'organisations', organisation_uuid,
            'users',         user_uuid
          ].join('/')
        )
      end
    end
  end
end
