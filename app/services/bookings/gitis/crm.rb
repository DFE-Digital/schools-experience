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
          filter: email_filter(address),
          limit: 1

        if contacts.any?
          contacts.first.tap do |c|
            crmlog "Read contact #{c.contactid}"
          end
        end
      end

      # Will return nil of it cannot match a Contact on final implementation
      def find_contact_for_signin(email:, firstname:, lastname:, date_of_birth:)
        filter = email_filter(email)
        contacts = fetch(Contact, filter: filter, limit: 30, order: 'createdon desc')

        matcher = ContactFuzzyMatcher.new(firstname, lastname, date_of_birth)
        matcher.find(contacts).tap do |match|
          crmlog "Read contact #{match.contactid}" if match
        end
      end

      def log_school_experience(contact_id, logline)
        contact = find(contact_id)
        return false unless contact

        contact.add_school_experience(logline)
        write contact
      end

    private

      def email_filter(email_address)
        FilterBuilder \
          .new(:emailaddress2, email_address)
          .or(:emailaddress1, email_address)
      end

      def crmlog(msg)
        logger.warn "[CRM] #{msg}"
      end
    end
  end
end
