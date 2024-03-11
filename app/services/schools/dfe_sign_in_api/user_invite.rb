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

      def invite_user
        @response = response
        @response['success'] = @response['status'] == 'success' if @response.present?
        @response
      end

    private

      def response
        raise ApiDisabled unless enabled?

        resp = faraday.post(endpoint) do |req|
          req.headers['Authorization'] = "bearer #{token}"
          req.headers['Content-Type'] = 'application/json'
          req.body = payload.to_json
        end

        JSON.parse(resp.body)
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
          organisationId: organisation_id
        )
      end
    end
  end
end
