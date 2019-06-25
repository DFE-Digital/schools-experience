module Candidates
  module Registrations
    class ContactInformation < RegistrationStep
      # These are here purely for compatibility with legacy data in Redis
      if Rails.application.config.x.phase <= 3
        attribute :first_name
        attribute :last_name
        attribute :full_name
        attribute :email
      end

      attribute :building
      attribute :street
      attribute :town_or_city
      attribute :county
      attribute :postcode
      attribute :phone

      validates :phone, presence: true
      validates :phone, phone: true, if: -> { phone.present? }
      validates :building, presence: true
      validates :postcode, presence: true
      validate :postcode_is_valid, if: -> { postcode.present? }

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
