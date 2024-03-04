module Schools
  module DFESignInAPI
    class UserInvite
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :email, :string
      attribute :first_name, :string
      attribute :last_name, :string
      attribute :organisation_id, :string
      # attribute :redirect_url, :string

      validates :first_name, presence: true, length: { maximum: 50 }
      validates :last_name, presence: true, length: { maximum: 50 }
      validates :email, presence: true, length: { maximum: 100 }
      validates :email, email_format: true, if: -> { email.present? }
      # validates :organisation_id, presence: true
      # validates :redirect_url, presence: true

      def invite_user
        raise ApiDisabled unless client.enabled?

        client.invite_user(merged_payload)
      end

      def full_name
        return nil unless first_name && last_name

        [first_name, last_name].map(&:presence).join(' ')
      end

      private

      def service_id
        ENV.fetch('DFE_SIGNIN_SCHOOL_EXPERIENCE_ADMIN_SERVICE_ID')
      end

      def endpoint
        URI::HTTPS.build(
          host: Rails.configuration.x.dfe_sign_in_api_host,
          path: ['/services', service_id, 'invitations'].join('/')
        )
      end

      def payload
        {
          sourceId: null,
          given_name: first_name,
          family_name: last_name,
          email: email,
          callback: redirect_url,
          organisationId: organisation_id
        }
      end

      # def initialize(email:, first_name:, last_name:, organisation_id:)
      #   @email = email
      #   @first_name = first_name
      #   @last_name = last_name
      #   @organisation_id = organisation_id
      # end

      #   def call
      #     invite_user
      #   end

      #   def invite_user
      #     response = client.post(
      #       '/users/invite',
      #       {
      #         email: email,
      #         firstName: first_name,
      #         lastName: last_name,
      #         organisationId: organisation_id
      #       }
      #     )

      #     response.body
      #   end
    end
  end
end
