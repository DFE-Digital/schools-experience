module Schools
  module PlacementRequests
    module Acceptance
      extend ActiveSupport::Concern

      def set_placement_request_and_fetch_gitis_contact
        @placement_request = @current_school.placement_requests \
          .find(params[:placement_request_id])

        assign_gitis_contact @placement_request
      end

      def find_or_build_booking(placement_request)
        placement_request.booking || Bookings::Booking.from_placement_request(placement_request)
      end
    end
  end
end
