module Schools
  class PreviousBookingsController < Schools::BaseController
    def index
      @bookings = current_school
        .bookings
        .historical
        .order(date: :desc)
        .page(params[:page])
        .per(50)
    end
  end
end
