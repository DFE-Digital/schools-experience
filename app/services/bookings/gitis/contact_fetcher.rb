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

          if contacts.key?(candidate.gitis_uuid)
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

      def been_merged?(contact)
        raise Contact::InconsistentState unless contact.merged == contact.master_id.present?

        contact.merged
      end

      class NoGitisUuid < RuntimeError; end

    private

      def fetch_single_master_contact(contactid)
        contact = nil

        1.upto(MAX_NESTING) do
          contact = fetch_contact(contactid)
          break unless been_merged?(contact)

          contactid = contact.master_id
        end

        contact
      end

      def fetch_multiple_master_contacts(contactids)
        contacts = fetch_contact(contactids).index_by(&:candidate_id)

        2.upto(MAX_NESTING) do
          merged = contacts.values.select { |c| been_merged?(c) }
          break if merged.empty?

          masterids = merged.map(&:master_id)
          masters = fetch_contact(masterids).index_by(&:candidate_id)

          contacts.transform_values! do |contact|
            been_merged?(contact) ? masters[contact.master_id] : contact
          end
        end

        contacts
      end

      def missing_contact(candidate)
        Bookings::Gitis::MissingContact.new candidate.contact_uuid
      end

      def fetch_contact(id_or_ids)
        api = GetIntoTeachingApiClient::SchoolsExperienceApi.new

        if id_or_ids.is_a?(Array)
          api.get_schools_experience_sign_ups(id_or_ids)
        else
          api.get_schools_experience_sign_up(id_or_ids)
        end
      end
    end
  end
end
