module Schools
  module DFESignInAPI
    class Roles < Client
      attr_accessor :user_uuid, :organisation_uuid

      class << self
        def service_id
          ENV.fetch('DFE_SIGNIN_SCHOOL_EXPERIENCE_ADMIN_SERVICE_ID').presence ||
            raise(MissingConfigVariable)
        end

        def role_id
          ENV.fetch('DFE_SIGNIN_SCHOOL_EXPERIENCE_ADMIN_ROLE_ID').presence ||
            raise(MissingConfigVariable)
        end

        def enabled?
          super && Rails.application.config.x.dfe_sign_in_api_role_check_enabled
        end
      end

      def initialize(user_uuid, organisation_uuid)
        self.user_uuid          = user_uuid
        self.organisation_uuid  = organisation_uuid
      end

      def has_school_experience_role?
        roles.any? { |role| role['id'] == self.class.role_id }
      rescue NoOrganisationError
        false
      end

      class MissingConfigVariable < RuntimeError; end
      class NoOrganisationError < RuntimeError; end

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
        fail NoOrganisationError,
          "Organisation '#{organisation_uuid}' not found for user '#{user_uuid}'"
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
