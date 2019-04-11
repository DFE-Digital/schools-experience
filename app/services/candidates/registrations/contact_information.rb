module Candidates
  module Registrations
    class ContactInformation < RegistrationStep
      attribute :full_name
      attribute :email
      attribute :building
      attribute :street
      attribute :town_or_city
      attribute :county
      attribute :postcode
      attribute :phone

      validates :full_name, presence: true
      validates :email, presence: true
      validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { email.present? }
      validates :building, presence: true
      validates :postcode, presence: true
      validate :postcode_is_valid, if: -> { postcode.present? }
      validates :phone, presence: true
      validates :phone, phone: true, if: -> { phone.present? }

    private

      def postcode_is_valid
        unless postcode_is_valid?
          errors.add :postcode, :invalid
        end
      end

      def postcode_is_valid?
        UKPostcode.parse(postcode).full_valid?
      end
    end
  end
end
