module Schools
  class PreviousBookingsController < Schools::BaseController
    def index
      @bookings = scope
        .includes(:bookings_subject, bookings_placement_request:
          %i[candidate candidate_cancellation school_cancellation])
        .order(date: :desc)
        .page(params[:page])

      assign_gitis_contacts @bookings
    end

    def show
      @booking = scope.find(params[:id])

      assign_gitis_contact @booking
    end

  private

    def scope
      current_school.bookings.historical
    end
  end
end
