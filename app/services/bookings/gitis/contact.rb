module Bookings
  module Gitis
    class Contact
      include ActiveModel::Model

      attr_reader :id
      attr_accessor :firstname, :lastname, :email, :phone
      attr_accessor :building, :street, :town_or_city, :county, :postcode

      validates :email, presence: true, format: /\A.+@.+\..+\z/

      def initialize(crm_contact_data = {})
        @crm_data     = crm_contact_data
        @id           = @crm_data['contactid']
        @firstname    = @crm_data['firstname']
        @lastname     = @crm_data['lastname']
        @email        = parse_email_from_crm(@crm_data)
        @phone        = parse_phone_from_crm(@crm_data)
        @building     = @crm_data['address1_line1']
        @street       = parse_street_from_crm(@crm_data)
        @town_or_city = @crm_data['address1_city']
        @county       = @crm_data['address1_stateorprovince']
        @postcode     = @crm_data['address1_postalcode']
      end

      def address
        [@building, @street, @town_or_city, @county, @postcode].compact.join(", ")
      end

      def id=(assigned_id)
        if @id.blank?
          @id = assigned_id.to_s
        elsif @id.to_s != assigned_id.to_s
          fail ContactIdChangedUnexpectedly
        end
      end

      def crm_data
        {} # STUBBED FOR NOW
      end

      def full_name
        "#{@firstname} #{@lastname}"
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
