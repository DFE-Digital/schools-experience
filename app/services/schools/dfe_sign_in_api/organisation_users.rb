module Schools
  module DFESignInAPI
    class OrganisationUsers < Client
      attr_accessor :user_uuid, :current_school_urn

      def initialize(user_uuid, current_school_urn)
        self.user_uuid = user_uuid
        self.current_school_urn = current_school_urn
      end

      def ukprn
        Organisation.new(user_uuid, current_school_urn).current_organisation_ukprn
      end

      def users
        response&.fetch('users', nil)
        # users_as_invite_objects
      end

      def users_as_invite_objects
        return [] if users.blank?

        users.map do |user_data|
          Schools::DFESignInAPI::UserInvite.new(
            email: user_data['email'],
            firstname: user_data['firstName'],
            lastname: user_data['lastName'],
            organisation_id: current_school_urn
          )
        end
      end

    private

      def endpoint
        URI::HTTPS.build(
          host: Rails.configuration.x.dfe_sign_in_api_host,
          path: ['/organisations', ukprn, 'users'].join('/')
        )
      end
    end
  end
end
