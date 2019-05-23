module Bookings
  module Gitis
    class Contact
      include Entity

      attr_reader :id
      entity_attributes :firstname, :lastname, :email, :phone
      entity_attributes :building, :street, :town_or_city, :county, :postcode

      validates :email, presence: true, format: /\A.+@.+\..+\z/

      def initialize(crm_contact_data = {})
        @crm_data         = crm_contact_data.stringify_keys
        self.id           = @crm_data['contactid']
        self.firstname    = @crm_data['firstname']
        self.lastname     = @crm_data['lastname']
        self.email        = parse_email_from_crm(@crm_data)
        self.phone        = parse_phone_from_crm(@crm_data)
        self.building     = @crm_data['address1_line1']
        self.street       = parse_street_from_crm(@crm_data)
        self.town_or_city = @crm_data['address1_city']
        self.county       = @crm_data['address1_stateorprovince']
        self.postcode     = @crm_data['address1_postalcode']
      end

      def address
        [building, street, town_or_city, county, postcode].compact.join(", ")
      end

      def id=(assigned_id)
        if @id.blank?
          @id = assigned_id
        elsif @id.to_s != assigned_id.to_s
          fail ContactIdChangedUnexpectedly
        end
      end

      def full_name
        "#{firstname} #{lastname}"
      end

      class ContactIdChangedUnexpectedly < RuntimeError; end

    private

      def parse_email_from_crm(data)
        data['emailaddress1'].presence ||
          data['emailaddress2'].presence ||
          data['emailaddress3']
      end

      def parse_phone_from_crm(data)
        data['mobilephone'].presence || data['telephone1']
      end

      def parse_street_from_crm(data)
        [
          data['address1_line2'].presence,
          data['address1_line3'].presence
        ].compact.join(', ')
      end
    end
  end
end
