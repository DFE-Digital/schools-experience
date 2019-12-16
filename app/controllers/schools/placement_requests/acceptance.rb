module Schools
  module PlacementRequests
    module Acceptance
      extend ActiveSupport::Concern

      def set_placement_request
        @placement_request = @current_school
          .bookings_placement_requests
          .find(params[:placement_request_id])

        @placement_request.fetch_gitis_contact gitis_crm
      end

      def find_or_build_booking(placement_request)
        placement_request.booking || Bookings::Booking.from_placement_request(placement_request)
      end
    end
  end
end
