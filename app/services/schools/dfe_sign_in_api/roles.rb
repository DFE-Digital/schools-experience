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
        roles.any? { |role| role['id'] == ENV.fetch('DFE_SIGNIN_SCHOOL_EXPERIENCE_ADMIN_ROLE_ID') }
      end

    private

      def roles
        @response ||= response

        unless @response.is_a?(Hash) && @response.has_key?('roles')
          fail APIResponseError, 'invalid response from roles API'
        end

        @response.fetch('roles')
      end

      # rather than request the UUID every time, as there's a 1:1 mapping with URN
      # on the DfE Sign-in end store it with the School
      def organisation_uuid
        find_organisation_uuid || retrieve_organisation_uuid
      end

      def find_organisation_uuid
        Bookings::School
          .select(:dfe_signin_organisation_uuid)
          .find_by(urn: urn)
          &.dfe_signin_organisation_uuid
      end

      def retrieve_organisation_uuid
        Schools::DFESignInAPI::Organisations
          .new(user_uuid)
          .id(urn)
          .tap do |org_uuid|
            fail NoOrganisationError, "No organisation ID found for user #{user_uuid}" unless org_uuid.present?

            Bookings::School.find_by(urn: urn).update!(dfe_signin_organisation_uuid: org_uuid)
          end
      end

      def endpoint
        URI::HTTPS.build(
          host: Rails.configuration.x.dfe_sign_in_api_host,
          path: [
            '/services',     ENV.fetch('DFE_SIGNIN_SCHOOL_EXPERIENCE_ADMIN_SERVICE_ID'),
            'organisations', organisation_uuid,
            'users',         user_uuid
          ].join('/')
        )
      end
    end
  end
end
