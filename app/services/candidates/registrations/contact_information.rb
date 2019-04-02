module Candidates
  module Registrations
    class ContactInformation < RegistrationStep
      POSTCODE_REGEXP = /([Gg][Ii][Rr] 0[Aa]{2})|((([A-Za-z][0-9]{1,2})|(([A-Za-z][A-Ha-hJ-Yj-y][0-9]{1,2})|(([A-Za-z][0-9][A-Za-z])|([A-Za-z][A-Ha-hJ-Yj-y][0-9][A-Za-z]?))))\s?[0-9][A-Za-z]{2})/.freeze

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
      validates :postcode, format: { with: POSTCODE_REGEXP }, if: -> { postcode.present? }
      validates :phone, presence: true
      validates :phone, phone: true, if: -> { phone.present? }
    end
  end
end
