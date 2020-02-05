module Bookings
  module Gitis
    class CRM
      delegate :logger, to: Rails
      delegate :fetch, :write, :write!, to: :store

      attr_reader :store

      def initialize(store)
        @store = store
      end

      def find(uuids, entity_type: Contact, includes: nil)
        store.find(entity_type, uuids, includes: includes)
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

      def log_school_experience(contact_id, logline)
        contact = find(contact_id)
        return false unless contact

        contact.add_school_experience(logline)
        write contact
      end

    private

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
