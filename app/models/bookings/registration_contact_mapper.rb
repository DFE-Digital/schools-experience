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
      gitis_contact.email ||= personal_information.email
      gitis_contact.secondary_email = personal_information.email
      gitis_contact.date_of_birth = personal_information.date_of_birth

      gitis_contact.secondary_telephone = contact_information.phone
      gitis_contact.telephone ||= contact_information.phone
      gitis_contact.address_telephone ||= contact_information.phone
      gitis_contact.address_line1 = contact_information.building
      gitis_contact.address_line2 = contact_information.street
      gitis_contact.address_line3 = ""
      gitis_contact.address_city = contact_information.town_or_city
      gitis_contact.address_state_or_province = contact_information.county
      gitis_contact.address_postcode = contact_information.postcode

      if background_check.has_dbs_check != gitis_contact.has_dbs_certificate
        gitis_contact.dbs_certificate_issued_at = nil
      end

      gitis_contact.has_dbs_certificate = background_check.has_dbs_check

      gitis_contact.preferred_teaching_subject_id = api_subject_id_from_gitis_value(teaching_preference.subject_first_choice)
      gitis_contact.secondary_preferred_teaching_subject_id = api_subject_id_from_gitis_value(teaching_preference.subject_second_choice)

      gitis_contact.accepted_policy_id = current_privacy_policy.id

      gitis_contact
    end

    def contact_to_contact_information
      {
        'phone' => gitis_contact.secondary_telephone.presence || gitis_contact.telephone.presence || gitis_contact.mobile_telephone,
        'building' => gitis_contact.address_line1,
        'street' => gitis_contact.address_line2,
        'town_or_city' => gitis_contact.address_city,
        'county' => gitis_contact.address_state_or_province,
        'postcode' => gitis_contact.address_postcode
      }
    end

    def contact_to_personal_information
      {
        'first_name' => gitis_contact.first_name,
        'last_name' => gitis_contact.last_name,
        'email' => gitis_contact.email&.strip,
        'date_of_birth' => gitis_contact.date_of_birth
      }
    end

    def contact_to_background_check
      {
        'has_dbs_check' => gitis_contact.has_dbs_certificate
      }
    end

    def contact_to_teaching_preference
      {
        'subject_first_choice' =>
          api_subject_from_gitis_uuid(gitis_contact.preferred_teaching_subject_id),
        'subject_second_choice' =>
          api_subject_from_gitis_uuid(gitis_contact.secondary_preferred_teaching_subject_id)
      }
    end

  private

    def current_privacy_policy
      policy_id = Rails.configuration.x.gitis.privacy_policy_id

      @current_privacy_policy ||= begin
        api = GetIntoTeachingApiClient::PrivacyPoliciesApi.new
        api.get_privacy_policy(policy_id)
      end
    end

    def find_teaching_subjects
      @find_teaching_subjects ||= begin
        subjects = Bookings::Subject.where(name: [
          teaching_preference.subject_first_choice,
          teaching_preference.subject_second_choice
        ]).index_by(&:name)

        {
          'dfe_teachingsubject01' =>
            subjects[teaching_preference.subject_first_choice]&.gitis_uuid,
          'dfe_teachingsubject02' =>
            subjects[teaching_preference.subject_second_choice]&.gitis_uuid
        }
      end
    end

    def api_subject_id_from_gitis_value(value)
      return nil if value.blank?

      teaching_subjects.find { |s| s.value == value }&.id
    end

    def api_subject_from_gitis_uuid(uuid)
      return nil if uuid.blank?

      teaching_subjects.find { |s| s.id == uuid }&.value
    end

    def teaching_subjects
      @teaching_subjects ||= begin
        api = GetIntoTeachingApiClient::LookupItemsApi.new
        api.get_teaching_subjects
      end
    end
  end
end
