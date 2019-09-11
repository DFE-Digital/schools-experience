module Candidates
  module Registrations
    class GitisRegistrationSession < RegistrationSession
      attr_reader :gitis_contact

      def initialize(session, gitis_contact)
        @gitis_contact = gitis_contact
        super(session)
      end

      def personal_information_attributes
        # default with GiTiS attributes if no personal info
        # override anything set for which there's a gitis equivalent
        # finally lock it with read only

        fetch_attributes(PersonalInformation, mapper.contact_to_personal_information).
          merge(completed_contact_fields_for_personal_information).
          merge('read_only' => true)
      end

      def personal_information
        PersonalInformation.new personal_information_attributes
      end

      def contact_information_attributes
        fetch_attributes ContactInformation, mapper.contact_to_contact_information
      end

      def background_check_attributes
        fetch_attributes BackgroundCheck, mapper.contact_to_background_check
      end

      def teaching_preference_attributes
        fetch_attributes TeachingPreference, mapper.contact_to_teaching_preference
      end

      def mapper
        @mapper ||= Bookings::RegistrationContactMapper.new(self, gitis_contact)
      end

    private

      def completed_contact_fields_for_personal_information
        # Ignore blank fields in Gitis and fall back to our data for validation purposes

        mapper.contact_to_personal_information.reject do |_key, value|
          value.blank?
        end
      end
    end
  end
end
