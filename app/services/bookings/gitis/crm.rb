module Bookings
  module Gitis
    class CRM
      prepend FakeCrm if Rails.application.config.x.fake_crm

      def initialize(token, service_url: nil, endpoint: nil)
        @token = token
        @service_url = service_url
        @endpoint = endpoint
      end

      def find(uuids, entity_type: Contact)
        multiple_ids = uuids.is_a?(Array)

        uuids = normalise_ids(uuids)
        validate_ids(uuids)

        # ensure we can't accidentally pull too much data
        params = { '$top' => uuids.length }

        if multiple_ids
          find_many(entity_type, uuids, params)
        else
          find_one(entity_type, uuids[0], params)
        end
      end

      def find_by_email(address)
        contacts = api.get("contacts", '$top' => 1, '$filter' => filter_pairs(
          emailaddress2: address,
          emailaddress1: address
        ))['value']

        Contact.new(contacts[0]) if contacts.any?
      end

      # Will return nil of it cannot match a Contact on final implementation
      def find_contact_for_signin(email:, firstname:, lastname:, date_of_birth:)
        find_possible_signin_contacts(email, 20) \
          .map(&Contact.method(:new))
          .find do |contact|
            contact.signin_attributes_match?(firstname, lastname, date_of_birth)
          end
      end

      def write(entity)
        raise ArgumentError unless entity.class < Entity
        return false unless entity.valid?

        # Sorting to allow stubbing http requests
        # webmock compares the request body as a serialized string
        data = entity.changed_attributes.sort.to_h

        if entity.id
          update_entity(entity.entity_id, data)
        else
          entity.entity_id = create_entity(entity.entity_id, data)
        end

        entity.id
      end

      class InvalidApiError < RuntimeError; end

    private

      def api
        @api ||= API.new(@token, service_url: @service_url, endpoint: @endpoint)
      end

      def normalise_ids(ids)
        Array.wrap(ids).flatten
      end

      def validate_ids(ids)
        if ids.empty?
          fail ArgumentError, "No Contact Ids supplied"
        else
          ids.each { |id| validate_id id }
        end
      end

      def validate_id(id)
        return true if id =~ Entity::ID_FORMAT

        fail ArgumentError, "Invalid Entity Id"
      end

      def filter_pairs(filter_data, join_with = 'or')
        parts = filter_data.map do |key, values|
          Array.wrap(values).map do |value|
            "#{key} eq '#{value}'"
          end
        end

        parts.join(" #{join_with} ")
      end

      def create_entity(entity_id, data)
        api.post(entity_id, data)
      end

      def update_entity(entity_id, data)
        api.patch(entity_id, data)
      end

      def find_one(entity_type, uuid, params)
        entity_type.new api.get("#{entity_type.entity_path}(#{uuid})", params)
      end

      def find_many(entity_type, uuids, params)
        params['$filter'] = filter_pairs(entity_type.primary_key => uuids)

        api.get(entity_type.entity_path, params)['value'].map do |entity_data|
          entity_type.new entity_data
        end
      end

      def find_possible_signin_contacts(email, max)
        filter = filter_pairs(emailaddress2: email, emailaddress1: email)
        api.get(
          'contacts',
          '$top' => max,
          '$filter' => filter#,
#          '$order' => #FIXME
        )['value']
      end
    end
  end
end
