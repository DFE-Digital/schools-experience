module Bookings
  module Gitis
    class CRM
      delegate :logger, to: Rails
      delegate :fetch, to: :store

      attr_reader :store

      def initialize(store)
        @store = store
      end

      def find(uuids, entity_type: Contact, includes: nil)
        multiple_ids = uuids.is_a?(Array)

        uuids = normalise_ids(uuids)
        validate_ids(uuids)

        # ensure we can't accidentally pull too much data
        params = { '$top' => uuids.length }

        expand = Array.wrap(includes).map(&:to_s).join(',')

        if expand.present?
          params['$expand'] = expand
          crmlog "READING #{entity_type} #{uuids.inspect} with #{expand}"
        else
          crmlog "READING #{entity_type} #{uuids.inspect}"
        end

        if multiple_ids
          store.find_many(entity_type, uuids, params)
        else
          store.find_one(entity_type, uuids[0], params)
        end
      end

      def find_by_email(address)
        contacts = store.fetch Contact,
          filter: filter_pairs(emailaddress2: address, emailaddress1: address),
          limit: 1

        if contacts.any?
          contacts.first.tap do |c|
            crmlog "Read contact #{c.contactid}"
          end
        end
      end

      # Will return nil of it cannot match a Contact on final implementation
      def find_contact_for_signin(email:, firstname:, lastname:, date_of_birth:)
        filter = filter_pairs(emailaddress2: email, emailaddress1: email)

        store.fetch(Contact, filter: filter, limit: 20, order: 'createdon desc')
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
          store.update_entity entity.entity_id, attrs if attrs.any?
        else
          attrs = entity.attributes_for_create.sort.to_h
          crmlog "INSERTING #{entity.entity_id}, SETTING #{attrs.keys.inspect}"
          entity.entity_id = store.create_entity entity.entity_id, attrs
        end

        entity.id
      end

      def log_school_experience(contact_id, logline)
        contact = find(contact_id)
        return false unless contact

        contact.add_school_experience(logline)
        write contact
      end

    private

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

      def crmlog(msg)
        logger.warn "[CRM] #{msg}"
      end
    end
  end
end
