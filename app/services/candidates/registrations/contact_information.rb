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
      validates :phone, presence: true
      validates :phone, phone: true, if: -> { phone.present? }
    end
  end
end
