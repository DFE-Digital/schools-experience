module Candidates
  module Registrations
    class ContactInformation < RegistrationStep
      attribute :building
      attribute :street
      attribute :town_or_city
      attribute :county
      attribute :postcode
      attribute :phone

      validates :phone,
        presence: true,
        length: { maximum: 50 }

      validates :phone, phone: true, if: -> { phone.present? }

      validates :building,
        presence: true,
        length: { maximum: 250 }

      validates :street, length: { maximum: 250 }
      validates :town_or_city, length: { maximum: 80 }
      validates :county, length: { maximum: 50 }

      validates :postcode,
        presence: true,
        length: { maximum: 20 }

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
