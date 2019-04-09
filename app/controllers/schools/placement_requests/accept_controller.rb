module Schools
  module PlacementRequests
    class DummyContact
      include ActiveModel::Model
      attr_accessor :contact_name, :telephone_number, :email_address, :location, :other_details
    end

    class AcceptController < Schools::BaseController
      def show
        @placement_request = placement_request
        @dummy_contact = dummy_contact
      end

      def create
        # blah
      end

    private

      def placement_request
        OpenStruct.new(
          school_name: "Newton Heath School", # get from current_school
          dates: "01 to 05 June 2019",
          details: "You'll be observing lessons and may get the change to interact with pupils and classroom activities.",
          requested_subject: "Maths",
          received_on: "02 February 2019"
        )
      end

      def dummy_contact
        Schools::PlacementRequests::DummyContact.new
        # contact_name: 'Joey',
        # telephone_number: '07123 345 4567',
        # email_address: 'joey@shabadoo.org',
        # location: 'Manchester',
        # other_details: 'Yes, there are some'
      end
    end
  end
end
