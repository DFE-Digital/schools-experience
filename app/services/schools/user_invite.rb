module Schools
  class UserInvite
    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :email, :string
    attribute :first_name, :string
    attribute :last_name, :string
    attribute :organisation_id, :string
    # attribute :role, :string
    # attribute :service_id, :string
    # attribute :redirect_url, :string

    validates :first_name, presence: true, length: { maximum: 50 }, unless: :read_only
    validates :last_name, presence: true, length: { maximum: 50 }, unless: :read_only
    validates :email, presence: true, length: { maximum: 100 }
    validates :email, email_format: true, if: -> { email.present? }
    # validates :organisation_id, presence: true
    # validates :role, presence: true
    # validates :service_id, presence: true
    # validates :redirect_url, presence: true

    # def self.compose(email:, first_name:, last_name:, organisation_id:, role:, service_id:, redirect_url:)
    #   new \
    #     email: email,
    #     first_name: first_name,
    #     last_name: last_name,
    #     organisation_id: organisation_id,
    #     role: role,
    #     service_id: service_id,
    #     redirect_url: redirect_url
    # end

    # def save
    #   return false unless valid?

    #   DfESignIn::InviteUser.call(
    #     email: email,
    #     first_name: first_name,
    #     last_name: last_name,
    #     organisation_id: organisation_id,
    #     role: role,
    #     service_id: service_id,
    #     redirect_url: redirect_url
    #   )
    # end
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
  # module DfeSignInApi
  # end
end
