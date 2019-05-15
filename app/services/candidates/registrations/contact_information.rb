module Candidates
  module Registrations
    class ContactInformation < RegistrationStep
      # multi parameter date fields aren't yet support by AcitveModel so we
      # need to include the support for them from ActiveRecord
      include ActiveRecord::AttributeAssignment

      MIN_AGE = 18
      MAX_AGE = 100

      attribute :full_name
      attribute :date_of_birth, :date
      attribute :email
      attribute :building
      attribute :street
      attribute :town_or_city
      attribute :county
      attribute :postcode
      attribute :phone

      validates :full_name, presence: true
      validates :phone, presence: true
      validates :phone, phone: true, if: -> { phone.present? }
      validates :email, presence: true
      validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { email.present? }
      validates :date_of_birth, presence: true
      validates :date_of_birth, inclusion: { in: ->(_) { MAX_AGE.years.ago..MIN_AGE.years.ago } }, if: -> { date_of_birth.present? }
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
