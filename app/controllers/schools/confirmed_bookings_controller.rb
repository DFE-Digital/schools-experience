module Schools
  class ConfirmedBookingsController < Schools::BaseController
    include Schools::RestrictAccessUnlessOnboarded

    def index
      @bookings = current_school
        .bookings
        .eager_load(:bookings_subject)
        .all
    end

    def show
      @booking = current_school
        .bookings
        .eager_load(:bookings_subject)
        .find(params[:id])
    end
  end
end
