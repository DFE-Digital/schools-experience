module Schools
  module ConfirmedBookings
    class UpcomingController < ConfirmedBookingsController
      def index
        @bookings = current_school
          .bookings
          .upcoming
          .eager_load(:bookings_subject, :bookings_placement_request)
          .all

        assign_gitis_contacts @bookings
      end
    end
  end
end
