module Candidates
  module Registrations
    class PersonalInformation < RegistrationStep
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
    end
  end
end
