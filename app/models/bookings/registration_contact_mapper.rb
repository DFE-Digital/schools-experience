module Bookings
  class RegistrationContactMapper
    attr_reader :registration_session, :gitis_contact

    delegate :personal_information, :contact_information, :education, :teaching_preference,
      :placement_preference, :background_check, to: :registration_session

    def initialize(registration_session, gitis_contact)
      @registration_session = registration_session
      @gitis_contact = gitis_contact
      @is_api_contact = gitis_contact.is_a?(GetIntoTeachingApiClient::SchoolsExperienceSignUp)
    end

    def registration_to_contact
      if @is_api_contact
        api_registration_to_contact
      else
        direct_registration_to_contact
      end
    end

    def contact_to_contact_information
      if @is_api_contact
        api_contact_to_contact_information
      else
        direct_contact_to_contact_information
      end
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
      if @is_api_contact
        {
          'has_dbs_check' => gitis_contact.has_dbs_certificate
        }
      else
        {
          'has_dbs_check' => gitis_contact.has_dbs_check
        }
      end
    end

    def contact_to_teaching_preference
      if @is_api_contact
        api_contact_to_teaching_preference
      else
        direct_contact_to_teaching_preference
      end
    end

  private

    def direct_registration_to_contact
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

      gitis_contact.dfe_PreferredTeachingSubject01 = find_teaching_subjects['dfe_teachingsubject01']
      gitis_contact.dfe_PreferredTeachingSubject02 = find_teaching_subjects['dfe_teachingsubject02']

      gitis_contact
    end

    def api_registration_to_contact
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

      gitis_contact.accepted_policy_id = latest_privacy_policy.id

      gitis_contact
    end

    def api_contact_to_teaching_preference
      {
        'subject_first_choice' =>
          api_subject_from_gitis_uuid(gitis_contact.preferred_teaching_subject_id),
        'subject_second_choice' =>
          api_subject_from_gitis_uuid(gitis_contact.secondary_preferred_teaching_subject_id)
      }
    end

    def direct_contact_to_teaching_preference
      {
        'subject_first_choice' =>
          direct_subject_from_gitis_uuid(gitis_contact._dfe_preferredteachingsubject01_value),
        'subject_second_choice' =>
          direct_subject_from_gitis_uuid(gitis_contact._dfe_preferredteachingsubject02_value)
      }
    end

    def api_contact_to_contact_information
      {
        'phone' => gitis_contact.secondary_telephone.presence || gitis_contact.telephone.presence || gitis_contact.mobile_telephone,
        'building' => gitis_contact.address_line1,
        'street' => [gitis_contact.address_line1, gitis_contact.address_line2].map(&:presence).compact.join(', '),
        'town_or_city' => gitis_contact.address_city,
        'county' => gitis_contact.address_state_or_province,
        'postcode' => gitis_contact.address_postcode
      }
    end

    def direct_contact_to_contact_information
      {
        'phone' => gitis_contact.phone,
        'building' => gitis_contact.building,
        'street' => gitis_contact.street,
        'town_or_city' => gitis_contact.town_or_city,
        'county' => gitis_contact.county,
        'postcode' => gitis_contact.postcode
      }
    end

    def latest_privacy_policy
      @latest_privacy_policy ||= begin
        api = GetIntoTeachingApiClient::PrivacyPoliciesApi.new
        api.get_latest_privacy_policy
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

    def direct_subject_from_gitis_uuid(uuid)
      return nil if uuid.blank?

      @subjects_from_gitis_uuids ||= begin
        uuids = [
          gitis_contact._dfe_preferredteachingsubject01_value,
          gitis_contact._dfe_preferredteachingsubject02_value
        ].map(&:presence).compact

        Bookings::Subject.where(gitis_uuid: uuids).index_by(&:gitis_uuid)
      end

      @subjects_from_gitis_uuids[uuid]&.name
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
