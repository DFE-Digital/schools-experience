module Bookings
  module Gitis
    class CRM
      def initialize(token)
        @token = token
      end

      def find(*ids)
        ids = normalise_ids(*ids)

        validate_ids(ids)

        if ids.length == 1
          Contact.new(fake_account_data.merge('contactid' => ids[0]))
        else
          ids.map do |id|
            Contact.new(fake_account_data.merge('contactid' => id))
          end
        end
      end

      def find_by_email(address)
        Contact.new(fake_account_data).tap do |contact|
          contact.email = address
        end
      end

      # Will return nil of it cannot match a Contact on final implementation
      def find_contact_for_signin(email:, firstname:, lastname:, date_of_birth:)
        # if condition is to keep the linter happy about unused variables
        # temporary since this is a shim for now
        if firstname && lastname && date_of_birth
          find_by_email(email)
        end
      end

      def write(contact)
        raise ArgumentError unless contact.is_a?(Contact)
        return false unless contact.valid?

        contact.id = write_data(contact.crm_data)
      end

    private

      def normalise_ids(*ids)
        Array.wrap(ids).flatten
      end

      def validate_ids(ids)
        if ids.empty?
          fail ArgumentError, "No Contact Ids supplied"
        end
      end

      def fake_account_data
        {
          'contactid' => "d778d663-a022-4c4b-9962-e469ee179f4a",
          'firstname' => 'Matthew',
          'lastname' => 'Richards',
          'mobilephone' => '07123 456789',
          'telephone1' => '01234 567890',
          'emailaddress1' => 'first@thisaddress.com',
          'emailaddress2' => 'second@thisaddress.com',
          'emailaddress3' => 'third@thisaddress.com',
          'address1_line1' => 'First Line',
          'address1_line2' => 'Second Line',
          'address1_line3' => 'Third Line',
          'address1_city' => 'Manchester',
          'address1_stateorprovince' => 'Manchester',
          'address1_postalcode' => 'MA1 1AM'
        }
      end

      def write_data(crm_contact_data)
        crm_contact_data['contactid'].presence ||
          "75c5a32d-d603-4483-956f-236fee7c5784"
      end
    end
  end
end
