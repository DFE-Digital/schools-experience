module Bookings
  module Gitis
    class ContactFetcher
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

        candidate.gitis_contact = crm.find(candidate.gitis_uuid)
        model
      end

      class NoGitisUuid < RuntimeError; end
    end
  end
end
