module Bookings
  module Gitis
    class ContactFuzzyMatcher
      def initialize(firstname, lastname, birthdate)
        @firstname = firstname.downcase
        @lastname = lastname.downcase
        @birthdate = birthdate.to_formatted_s(:db)
      end

      def find(contacts)
        contacts.find(&method(:matches?))
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
    end
  end
end
