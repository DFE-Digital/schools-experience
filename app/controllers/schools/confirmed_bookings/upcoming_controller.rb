module Schools
  module ConfirmedBookings
    class UpcomingController < ConfirmedBookingsController
      def index
        @bookings = current_school
          .bookings
          .eager_load(:bookings_subject)
          .upcoming
          .order(date: :asc)
          .page(params[:page])
          .per(10)
      end
    end
  end
end
