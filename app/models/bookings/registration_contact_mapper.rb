module Bookings
  class RegistrationContactMapper
    attr_reader :registration_session, :gitis_contact

    delegate :personal_information, :contact_information, :education, :teaching_preference,
      :placement_preference, :background_check, to: :registration_session

    def initialize(registration_session, gitis_contact)
      @registration_session = registration_session
      @gitis_contact = gitis_contact
    end

    def registration_to_contact
      gitis_contact.first_name = personal_information.first_name
      gitis_contact.last_name = personal_information.last_name
      gitis_contact.email = personal_information.email
      gitis_contact.date_of_birth = personal_information.date_of_birth

      gitis_contact.phone = contact_information.phone
      gitis_contact.building = contact_information.building
      gitis_contact.street = contact_information.street
      gitis_contact.town_or_city = contact_information.town_or_city
      gitis_contact.county = contact_information.county
      gitis_contact.postcode = contact_information.postcode

      gitis_contact.has_dbs_check = background_check.has_dbs_check

      gitis_contact
    end

    def contact_to_contact_information
      {
        'phone'         => gitis_contact.phone,
        'building'      => gitis_contact.building,
        'street'        => gitis_contact.street,
        'town_or_city'  => gitis_contact.town_or_city,
        'county'        => gitis_contact.county,
        'postcode'      => gitis_contact.postcode
      }
    end

    def contact_to_personal_information
      {
        'first_name'    => gitis_contact.first_name,
        'last_name'     => gitis_contact.last_name,
        'email'         => gitis_contact.email,
        'date_of_birth' => gitis_contact.date_of_birth
      }
    end

    def contact_to_background_check
      {
        'has_dbs_check' => gitis_contact.has_dbs_check
      }
    end
  end
end
