module Schools
  class ConfirmedBookingsController < Schools::BaseController
    def index
      @bookings = current_school
        .bookings
        .eager_load(:bookings_subject, :bookings_placement_request)
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
