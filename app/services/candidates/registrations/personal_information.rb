module Candidates
  module Registrations
    class PersonalInformation < RegistrationStep
      attribute :first_name
      attribute :last_name
      attribute :full_name
      attribute :email

      validates :first_name, presence: true
      validates :last_name, presence: true
      validates :email, presence: true
      validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { email.present? }

      def full_name
        full_name_attribute = super

        if full_name_attribute.present?
          return full_name_attribute
        end

        if first_name && last_name
          return [first_name, last_name].map(&:to_s).join(' ')
        end

        nil
      end
    end
  end
end
