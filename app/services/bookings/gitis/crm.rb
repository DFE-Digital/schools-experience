module Bookings
  module Gitis
    class CRM
      prepend FakeCrm if Rails.application.config.x.fake_crm

      def initialize(token, service_url: nil, endpoint: nil)
        @token = token
        @service_url = service_url
        @endpoint = endpoint
      end

      def find(*ids)
        ids = normalise_ids(*ids)
        validate_ids(ids)

        params = { '$top' => ids.length }

        if ids.length == 1
          Contact.new api.get("contacts(#{uuid})", params)
        else
          params['$filter'] = multiple_contactid_filter(uuids)

          api.get('contacts', params).map do |contact|
            Contact.new contact
          end
        end
      end

      def find_by_email(address)
        # FIXME TBD
      end

      def write(contact)
        raise ArgumentError unless contact.is_a?(Contact)
        return false unless contact.valid?

        contact.id = write_data(contact.crm_data)
      end

    private

      def normalise_ids(*ids)
        Array.wrap(ids).flatten
      end

      def validate_ids(ids)
        if ids.empty?
          fail ArgumentError, "No Contact Ids supplied"
        end
      end

      def write_data(crm_contact_data)
        # FIXME TBD
      end

      def api
        API.new(@token, @service_url, @endpoint)
      end

      def multiple_contactid_filter(uuids)
        uuids.map { |id| "contactid eq '#{id}'" }.join(' or ')
      end
    end
  end
end
