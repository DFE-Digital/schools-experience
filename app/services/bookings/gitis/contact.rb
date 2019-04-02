module Bookings
  module Gitis
    class Contact
      def initialize(crm_contact_data)
        @data = crm_contact_data
      end

      def id
        @data['AccountId']
      end

      def full_name
        @data['AccountIdName']
      end

      def email
        @data['EmailAddress1'].presence ||
        @data['EmailAddress2'].presence ||
        @data['EmailAddress3'].presence
      end

      def phone
        @data['MobilePhone'].presence || @data['Telephone1']
      end

      def building
        @data['Address1_Line1']
      end

      def street
        [
          @data['Address1_Line2'].presence,
          @data['Address1_Line3'].presence
        ].compact.join(', ')
      end

      def town_or_city
        @data['Address1_City']
      end

      def county
        @data['Address1_StateOrProvince']
      end

      def postcode
        @data['Address1_PostalCode']
      end
    end
  end
end
