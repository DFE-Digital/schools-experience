module Bookings
  module Gitis
    class ContactFetcher
      MAX_NESTING = 5 # max depth we will follow the chain of merged contacts to
      attr_reader :crm

      def initialize(crm)
        @crm = crm
      end

      def fetch_for_models(models)
        return {} if models.empty?

        contact_uuids = models.map(&:contact_uuid)
        fetch_multiple_master_contacts(contact_uuids)
      end

      def assign_to_models(models)
        contacts = fetch_for_models(models)

        models.each do |model|
          candidate = model.is_a?(Bookings::Candidate) ? model : model.candidate

          if contacts.has_key?(candidate.gitis_uuid)
            candidate.assign_gitis_contact contacts[candidate.gitis_uuid]
          else
            candidate.gitis_contact = missing_contact(candidate)
          end
        end
      end

      def assign_to_model(model)
        candidate = model.is_a?(Bookings::Candidate) ? model : model.candidate
        raise NoGitisUuid unless candidate.gitis_uuid?

        candidate.assign_gitis_contact \
          fetch_single_master_contact(candidate.gitis_uuid)

        model
      end

      class NoGitisUuid < RuntimeError; end

    private

      def fetch_single_master_contact(contactid)
        contact = nil

        1.upto(MAX_NESTING) do
          contact = crm.find contactid
          break unless contact.been_merged?

          contactid = contact._masterid_value
        end

        contact
      end

      def fetch_multiple_master_contacts(contactids)
        contacts = crm.find(contactids).index_by(&:contactid)

        2.upto(MAX_NESTING) do
          merged = contacts.values.select(&:been_merged?)
          break if merged.empty?

          masterids = merged.map(&:_masterid_value)
          masters = crm.find(masterids).index_by(&:contactid)

          contacts.transform_values! do |contact|
            contact.been_merged? ? masters[contact._masterid_value] : contact
          end
        end

        contacts
      end

      def missing_contact(candidate)
        Bookings::Gitis::MissingContact.new candidate.contact_uuid
      end
    end
  end
end
