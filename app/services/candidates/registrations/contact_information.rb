module Candidates
  module Registrations
    class ContactInformation < RegistrationStep
      attribute :first_name
      attribute :last_name
      attribute :full_name
      attribute :email
      attribute :building
      attribute :street
      attribute :town_or_city
      attribute :county
      attribute :postcode
      attribute :phone

      validates :first_name, presence: true
      validates :last_name, presence: true
      validates :phone, presence: true
      validates :phone, phone: true, if: -> { phone.present? }
      validates :email, presence: true
      validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { email.present? }
      validates :building, presence: true
      validates :postcode, presence: true
      validate :postcode_is_valid, if: -> { postcode.present? }

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
