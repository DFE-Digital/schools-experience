module Candidates
  module Registrations
    class PersonalInformation < RegistrationStep
      attr_reader :contact

      attribute :first_name
      attribute :last_name
      attribute :email

      validates :first_name, presence: true
      validates :last_name, presence: true
      validates :email, presence: true
      validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { email.present? }

      def full_name
        return nil unless first_name && last_name

        [first_name, last_name].map(&:presence).join(' ')
      end

      def create_signin_token(gitis_crm)
        build_candidate_session(gitis_crm).create_signin_token
      end

    private

      def build_candidate_session(gitis_crm)
        Candidates::Session.new(
          gitis_crm,
          firstname: first_name,
          lastname: last_name,
          email: email,
          date_of_birth: Date.new(1970, 1, 1) # FIXME waiting to integrate DOB branch
        )
      end
    end
  end
end
