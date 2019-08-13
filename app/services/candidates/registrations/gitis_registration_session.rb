module Candidates
  module Registrations
    class GitisRegistrationSession < RegistrationSession
      attr_reader :gitis_contact

      def initialize(session, gitis_contact)
        @gitis_contact = gitis_contact
        super(session)
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
