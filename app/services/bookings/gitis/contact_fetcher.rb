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

          if contacts.has_key? candidate.gitis_uuid
            candidate.gitis_contact = contacts[candidate.gitis_uuid]

            if candidate.gitis_uuid != candidate.gitis_contact.contactid
              candidate.update_column :gitis_uuid, candidate.gitis_contact.contactid
            end
          else
            candidate.gitis_contact = \
              Bookings::Gitis::MissingContact.new(model.contact_uuid)
          end
        end
      end

      def assign_to_model(model)
        candidate = model.is_a?(Bookings::Candidate) ? model : model.candidate

        raise NoGitisUuid unless candidate.gitis_uuid?

        candidate.gitis_contact = fetch_single_master_contact(candidate.gitis_uuid)

        if candidate.gitis_uuid != candidate.gitis_contact.contactid
          candidate.update_column :gitis_uuid, candidate.gitis_contact.contactid
        end

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
        contacts = nil
        parentids = contactids.dup

        1.upto(MAX_NESTING) do
          fetched = crm.find(parentids).index_by(&:contactid)

          if contacts.nil?
            contacts = fetched
          else
            contacts.transform_values! do |contact|
              if contact.been_merged?
                fetched[contact._masterid_value]
              else
                contact
              end
            end
          end

          if contacts.values.any?(&:been_merged?)
            parentids = contacts.values.select(&:been_merged?).map(&:_masterid_value)
          else
            return contacts
          end
        end

        contacts
      end
    end
  end
end
