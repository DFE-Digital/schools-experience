module Bookings
  module Gitis
    class CRM
      def initialize(token)
        @token = token
      end

      def find(*account_ids)
        account_ids = normalise_ids(*account_ids)

        validate_account_ids(account_ids)

        if account_ids.length == 1
          Contact.new(fake_account_data)
        else
          account_ids.map do
            Contact.new(fake_account_data)
          end
        end
      end

      def write(contact)
        raise ArgumentError unless contact.is_a?(Contact)
        return false unless contact.valid?

        contact.id = write_data(contact.crm_data)
      end

    private

      def normalise_ids(*account_ids)
        Array.wrap(account_ids).flatten
      end

      def validate_account_ids(account_ids)
        if account_ids.empty?
          fail ArgumentError, "No Account Ids supplied"
        end
      end

      def fake_account_data
        {
          'AccountId' => '1',
          'AccountIdName' => 'Timbuktoo',
          'MobilePhone' => '07123 456789',
          'Telephone1' => '01234 567890',
          'EmailAddress1' => 'first@thisaddress.com',
          'EmailAddress2' => 'second@thisaddress.com',
          'EmailAddress3' => 'third@thisaddress.com',
          'Address1_Line1' => 'First Address Line',
          'Address1_Line2' => 'Second Address Line',
          'Address1_Line3' => 'Third Address Line',
          'Address1_City' => 'Manchester',
          'Address1_StateOrProvince' => 'Manchester',
          'Address1_PostalCode' => 'MA1 1AM'
        }
      end

      def write_data(crm_contact_data)
        crm_contact_data['AccountId'].presence || 1
      end
    end
  end
end
