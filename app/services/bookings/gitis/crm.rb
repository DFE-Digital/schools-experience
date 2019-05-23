module Bookings
  module Gitis
    class CRM
      prepend FakeCrm if Rails.application.config.x.fake_crm

      def initialize(token, service_url: nil, endpoint: nil)
        @token = token
        @service_url = service_url
        @endpoint = endpoint
      end

      def find(*uuids)
        uuids = normalise_ids(*uuids)
        validate_ids(uuids)

        # ensure we can't accidentally pull too much data
        params = { '$top' => uuids.length }

        if uuids.length == 1
          Contact.new api.get("contacts(#{uuids[0]})", params)
        else
          params['$filter'] = filter_pairs(contactid: uuids)

          api.get('contacts', params)['value'].map do |contact|
            Contact.new contact
          end
        end
      end

      def find_by_email(address)
        contacts = api.get("contacts", '$top' => 1, '$filter' => filter_pairs(
          emailaddress1: address,
          emailaddress2: address,
          emailaddress3: address
        ))['value']


        Contact.new(contacts[0]) if contacts.any?
      end

      def write(entity)
        raise ArgumentError unless entity.class < Entity
        return false unless entity.valid?

        # Sorting to allow stubbing http requests
        # webmock compares the request body as a serialized string
        data = entity.changed_attributes.sort.to_h

        if entity.id
          api.patch(entity.entity_id, data)
        else
          entity.entity_id = api.post(entity.entity_id, data)
        end

        entity.id
      end

      class InvalidApiError < RuntimeError; end

    private

      def api
        @api ||= API.new(@token, service_url: @service_url, endpoint: @endpoint)
      end

      def normalise_ids(*ids)
        Array.wrap(ids).flatten
      end

      def validate_ids(ids)
        if ids.empty?
          fail ArgumentError, "No Contact Ids supplied"
        end
      end

      def filter_pairs(filter_data, join_with = 'or')
        parts = filter_data.map do |key, values|
          Array.wrap(values).map do |value|
            "#{key} eq '#{value}'"
          end
        end

        parts.join(" #{join_with} ")
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
    end
  end
end
