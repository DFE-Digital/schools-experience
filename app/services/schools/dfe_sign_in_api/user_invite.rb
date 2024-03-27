module Schools
  module DFESignInAPI
    class UserInvite < Client
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveRecord::AttributeAssignment

      attribute :email, :string
      attribute :firstname, :string
      attribute :lastname, :string
      attribute :organisation_id, :string

      validates :firstname, presence: true, length: { maximum: 50 }
      validates :lastname, presence: true, length: { maximum: 50 }
      validates :email, presence: true, length: { maximum: 100 }
      validates :email, email_format: true, if: -> { email.present? }
      validates :organisation_id, presence: true

      def create
        @response = response
        send_user_invite_email
      end

    private

      def send_user_invite_email
        NotifyEmail::SchoolUserInvite.new(
          to: email
        ).despatch_later!
      end

      def response
        raise ApiDisabled unless enabled?

        resp = faraday.post(endpoint) do |req|
          req.headers['Authorization'] = "bearer #{token}"
          req.headers['Content-Type'] = 'application/json'
          req.body = payload.to_json
        end

        resp.body
      end

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
        super.merge(
          sourceId: SecureRandom.uuid,
          given_name: firstname,
          family_name: lastname,
          email: email,
          organisation: organisation_id
        )
      end
    end
  end
end
