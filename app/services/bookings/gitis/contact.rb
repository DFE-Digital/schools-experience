module Bookings
  module Gitis
    class Contact
      include ActiveModel::Model

      attr_reader :id
      attr_accessor :full_name, :email, :phone
      attr_accessor :building, :street, :town_or_city, :county, :postcode

      validates :email, presence: true, format: /\A.+@.+\..+\z/

      def initialize(crm_contact_data = {})
        @crm_data     = crm_contact_data
        @id           = @crm_data['AccountId']
        @full_name    = @crm_data['AccountIdName']
        @email        = parse_email_from_crm(@crm_data)
        @phone        = parse_phone_from_crm(@crm_data)
        @building     = @crm_data['Address1_Line1']
        @street       = parse_street_from_crm(@crm_data)
        @town_or_city = @crm_data['Address1_City']
        @county       = @crm_data['Address1_StateOrProvince']
        @postcode     = @crm_data['Address1_PostalCode']
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

      class ContactIdChangedUnexpectedly < RuntimeError; end

    private

      def parse_email_from_crm(data)
        data['EmailAddress1'].presence ||
          data['EmailAddress2'].presence ||
          data['EmailAddress3']
      end

      def parse_phone_from_crm(data)
        data['MobilePhone'].presence || data['Telephone1']
      end

      def parse_street_from_crm(data)
        [
          data['Address1_Line2'].presence,
          data['Address1_Line3'].presence
        ].compact.join(', ')
      end
    end
  end
end
