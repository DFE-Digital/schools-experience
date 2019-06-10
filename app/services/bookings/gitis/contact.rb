module Bookings
  module Gitis
    class Contact
      include Entity

      attr_reader :id
      entity_attributes :firstname, :lastname, :emailaddress1, :emailaddress2
      entity_attributes :address1_line1, :address1_line2, :address1_line3
      entity_attributes :address1_city, :address1_stateorprovince
      entity_attributes :address1_postalcode, :phone

      alias_attribute :building, :address1_line1
      alias_attribute :town_or_city, :address1_city
      alias_attribute :county, :address1_stateorprovince
      alias_attribute :postcode, :address1_postalcode

      validates :email, presence: true, format: /\A.+@.+\..+\z/

      def initialize(crm_contact_data = {})
        @crm_data                     = crm_contact_data.stringify_keys
        self.id                       = @crm_data['contactid']
        self.firstname                = @crm_data['firstname']
        self.lastname                 = @crm_data['lastname']
        self.emailaddress1            = @crm_data['emailaddress1']
        self.emailaddress2            = @crm_data['emailaddress2']
        self.phone                    = parse_phone_from_crm(@crm_data)
        self.address1_line1           = @crm_data['address1_line1']
        self.address1_line2           = @crm_data['address1_line2']
        self.address1_line3           = @crm_data['address1_line3']
        self.address1_city            = @crm_data['address1_city']
        self.address1_stateorprovince = @crm_data['address1_stateorprovince']
        self.address1_postalcode      = @crm_data['address1_postalcode']
      end

      def address
        [building, street, town_or_city, county, postcode].compact.join(", ")
      end

      def email
        emailaddress2.presence || emailaddress1
      end

      def email=(emailaddress)
        if emailaddress1.blank?
          self.emailaddress1 = emailaddress
        elsif emailaddress1 != emailaddress
          self.emailaddress2 = emailaddress
        end
      end

      def street
        [address1_line2, address1_line3].map(&:presence).compact.join(', ')
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

      def parse_phone_from_crm(data)
        data['mobilephone'].presence || data['telephone1']
      end
    end
  end
end
