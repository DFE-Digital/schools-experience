module Schools
  module ConfirmedBookings
    class DateController < Schools::BaseController
      before_action :set_booking

      def edit
      end

      def update
        # do the update

        if @booking.update(booking_params)
          redirect_to schools_booking_path(@booking)
        else
          render :edit
        end

        # add an event
        # send an email
      end

    private

      def booking_params
        params.require(:bookings_booking).permit(:date)
      end

      def set_booking
        @booking = current_school
          .bookings
          .eager_load(bookings_placement_request: :candidate)
          .find(params[:booking_id])

        @booking
          .bookings_placement_request
          .fetch_gitis_contact(gitis_crm)
      end
    end
  end
end
