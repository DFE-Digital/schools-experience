module Schools
  class ConfirmedBookingsController < Schools::BaseController
    def index
      @bookings = current_school
        .bookings
        .requiring_attention
        .eager_load(:bookings_subject, bookings_placement_request: %i(candidate candidate_cancellation school_cancellation))
        .order(date: :asc)
        .page(params[:page])

      assign_gitis_contacts @bookings
    end

    def show
      @booking = current_school
        .bookings
        .eager_load(:bookings_subject, :bookings_placement_request)
        .find(params[:id])

      @booking.bookings_placement_request.fetch_gitis_contact gitis_crm

      if @booking.candidate_cancellation
        @booking.candidate_cancellation.viewed!
      end
    end
  end
end
