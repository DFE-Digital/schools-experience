module Bookings
  module Gitis
    class ContactFuzzyMatcher
      def initialize(firstname, lastname, birthdate)
        @firstname = firstname.downcase
        @lastname = lastname.downcase
        @birthdate = birthdate.to_formatted_s(:db)
      end

      def find(contacts)
        known, unknown = prioritise(contacts)

        known.find(&method(:matches?)) || unknown.find(&method(:matches?))
      end

    private

      def matches?(contact)
        compare(:firstname, contact) && compare(:lastname, contact) ||
          compare(:firstname, contact) && compare(:birthdate, contact) ||
          compare(:lastname, contact) && compare(:birthdate, contact)
      end

      def compare(attribute, contact)
        cvalue = contact.public_send(attribute).to_s.downcase
        cvalue == instance_variable_get("@#{attribute}")
      end

      def prioritise(contacts)
        contact_ids = contacts.map(&:contactid).compact

        candidates = Bookings::Candidate.
          where(gitis_uuid: contact_ids).
          pluck(:gitis_uuid)

        contacts.partition { |c| candidates.include? c.contactid }
      end
    end
  end
end
