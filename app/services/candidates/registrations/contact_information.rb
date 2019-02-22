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
      validates :building, presence: true
      validates :street, presence: true
      validates :town_or_city, presence: true
      validates :county, presence: true
      validates :postcode, presence: true
      validates :phone, presence: true
    end
  end
end
