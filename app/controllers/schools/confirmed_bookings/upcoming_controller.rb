module Schools
  module ConfirmedBookings
    class UpcomingController < ConfirmedBookingsController
      def index
        @bookings = current_school
          .bookings
          .upcoming
          .eager_load(:bookings_subject)
          .all
      end
    end
  end
end
