module Schools
  module ConfirmedBookings
    class DateController < Schools::BaseController
      before_action :set_booking
      before_action :check_editable, except: :show

      def edit; end

      def update
        old_date = @booking.date

        if @booking.update(booking_params)
          Event.create(
            event_type: :booking_date_changed,
            bookings_school: current_school,
            recordable: @booking
          )

          date_changed_email(@booking, old_date).despatch_later!

          redirect_to schools_booking_date_path(@booking)
        else
          render :edit
        end
      end

      def show; end

    private

      def date_changed_email(booking, old_date)
        NotifyEmail::CandidateBookingDateChanged.from_booking(
          booking.candidate_email,
          booking.candidate_name,
          booking,
          candidates_cancel_url(booking.token),
          old_date.to_formatted_s(:govuk)
        )
      end

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

      def check_editable
        return true if @booking.editable_date?

        render 'uneditable'
        false
      end
    end
  end
end
