module Bookings
  module Gitis
    class ContactFetcher
      MAX_NESTING = 5 # max depth we will try to unwind to
      attr_reader :crm

      def initialize(crm)
        @crm = crm
      end

      def fetch_for_models(models)
        return {} if models.empty?

        contact_uuids = models.map(&:contact_uuid)
        crm.find(contact_uuids).index_by(&:contactid)
      end

      def assign_to_models(models)
        contacts = fetch_for_models(models)

        models.each do |model|
          model.gitis_contact = contacts[model.contact_uuid] ||
            Bookings::Gitis::MissingContact.new(model.contact_uuid)
        end
      end

      def assign_to_model(model)
        candidate = model.is_a?(Bookings::Candidate) ? model : model.candidate

        raise NoGitisUuid unless candidate.gitis_uuid?

        candidate.gitis_contact = single_unmerged_contact(candidate.gitis_uuid)

        if candidate.gitis_uuid != candidate.gitis_contact.contactid
          candidate.update_column :gitis_uuid, candidate.gitis_contact.contactid
        end

        model
      end

      class NoGitisUuid < RuntimeError; end

    private

      def single_unmerged_contact(contactid)
        contact = nil

        1.upto(MAX_NESTING) do |i|
          contact = crm.find contactid
          break unless contact.been_merged?
          contactid = contact._masterid_value
        end

        contact
      end
    end
  end
end
