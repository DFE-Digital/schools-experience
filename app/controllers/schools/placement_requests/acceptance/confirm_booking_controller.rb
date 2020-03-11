module Schools
  module PlacementRequests
    module Acceptance
      class ConfirmBookingController < Schools::BaseController
        include Acceptance

        def new
          set_placement_request_and_fetch_gitis_contact

          @placement_request.fetch_gitis_contact gitis_crm
          @booking = find_or_build_booking(@placement_request)
          @last_booking_found = @booking.populate_contact_details
        end
      end
    end
  end
end
