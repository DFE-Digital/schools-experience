module Schools
  class ConfirmedBookingsController < Schools::BaseController
    def index
      # FIXME limit to user's current school
      @bookings = Bookings::Booking
        .eager_load(:bookings_subject)
        .all
    end

    def show
      @booking = Bookings::Booking.find(params[:id])
    end
  end
end
