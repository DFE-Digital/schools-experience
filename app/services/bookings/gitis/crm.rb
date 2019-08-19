module Bookings
  module Gitis
    class CRM
      prepend FakeCrm if Rails.application.config.x.gitis.fake_crm
      delegate :logger, to: Rails

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

        crmlog "READING Contacts #{uuids.inspect}"
        if multiple_ids
          find_many(entity_type, uuids, params)
        else
          find_one(entity_type, uuids[0], params)
        end
      end

      def find_by_email(address)
        params = {
          '$filter' => filter_pairs(emailaddress2: address, emailaddress1: address),
          '$select' => Contact.entity_attribute_names.to_a.join(','),
          '$top' => 1
        }

        contacts = api.get("contacts", params)['value']

        if contacts.any?
          Contact.new(contacts[0]).tap do |c|
            crmlog "Read contact #{c.contactid}"
          end
        end
      end

      def fetch(entity_type, filter: nil, limit: 10, order: nil)
        params = {
          '$select' => entity_type.entity_attribute_names.to_a.join(','),
          '$top' => limit
        }

        params['$filter'] = filter if filter.present?
        params['$orderby'] = order if order.present?

        records = api.get(entity_type.entity_path, params)['value']

        logline = "Read #{records.length} #{entity_type.to_s.pluralize} from Gitis"
        logline << " - filter: #{filter}" if filter.present?
        crmlog logline

        records.map do |record_data|
          entity_type.new(record_data)
        end
      end

      # Will return nil of it cannot match a Contact on final implementation
      def find_contact_for_signin(email:, firstname:, lastname:, date_of_birth:)
        filter = filter_pairs(emailaddress2: email, emailaddress1: email)

        fetch(Contact, filter: filter, limit: 20, order: 'createdon desc')
          .find { |c| c.signin_attributes_match? firstname, lastname, date_of_birth }
          .tap { |c| crmlog "Read contact #{c.contactid}" if c }
      end

      def write(entity)
        raise ArgumentError unless entity.class < Entity
        return false unless entity.valid?

        # Sorting attributes allows stubbed http requests
        # webmock compares the request body as a serialized string

        if entity.id
          attrs = entity.attributes_for_update.sort.to_h
          crmlog "UPDATING #{entity.entity_id}, SETTING #{attrs.keys.inspect}"
          update_entity entity.entity_id, attrs
        else
          attrs = entity.attributes_for_create.sort.to_h
          crmlog "INSERTING #{entity.entity_id}, SETTING #{attrs.keys.inspect}"
          entity.entity_id = create_entity entity.entity_id, attrs
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
        params['$select'] ||= entity_type.entity_attribute_names.to_a.join(',')

        entity_type.new api.get("#{entity_type.entity_path}(#{uuid})", params)
      end

      def find_many(entity_type, uuids, params)
        params['$filter'] = filter_pairs(entity_type.primary_key => uuids)
        params['$select'] ||= entity_type.entity_attribute_names.to_a.join(',')

        api.get(entity_type.entity_path, params)['value'].map do |entity_data|
          entity_type.new entity_data
        end
      end

      def crmlog(msg)
        logger.warn "[CRM] #{msg}"
      end
    end
  end
end
