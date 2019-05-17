module Schools
  module ConfirmedBookings
    class UpcomingController < ConfirmedBookingsController
      def index
        @bookings = Bookings::Booking
          .eager_load(:bookings_subject)
          .all
          # FIXME .upcoming
      end
    end
  end
end
