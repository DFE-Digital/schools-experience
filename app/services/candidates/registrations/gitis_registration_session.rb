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
          merge(mapper.contact_to_personal_information).
          merge('read_only' => true)
      end

      def personal_information
        PersonalInformation.new personal_information_attributes
      end

      def contact_information_attributes
        fetch_attributes ContactInformation, mapper.contact_to_contact_information
      end

      def mapper
        @mapper ||= Bookings::RegistrationContactMapper.new(self, gitis_contact)
      end
    end
  end
end
