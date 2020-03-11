module Bookings
  module Gitis
    class MissingContact
      attr_reader :id

      def initialize(uuid)
        @id = uuid
      end
      alias_method :contactid, :id

      def full_name
        'Unavailable'.freeze
      end
      alias_method :firstname, :full_name
      alias_method :lastname, :full_name

      def emailaddress2
        nil
      end
      alias_method :emailaddress1, :emailaddress2
      alias_method :email, :emailaddress2

      def birthdate
        nil
      end
      alias_method :date_of_birth, :birthdate
    end
  end
end
