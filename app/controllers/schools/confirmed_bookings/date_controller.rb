module Schools
  module ConfirmedBookings
    class DateController < Schools::BaseController
      before_action :set_booking
      before_action :check_editable, except: :show

      def edit; end

      def update
        old_date = @booking.date

        @booking.assign_attributes(booking_params)

        if @booking.save(context: :updating_date)
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
        if booking.virtual_experience?
          virtual_email(booking, old_date)
        else
          in_school_email(booking, old_date)
        end
      end

      def in_school_email(booking, old_date)
        NotifyEmail::CandidateBookingDateChanged.from_booking(
          booking.candidate_email,
          booking.candidate_name,
          booking,
          candidates_cancel_url(booking.token),
          old_date.to_formatted_s(:govuk)
        )
      end

      def virtual_email(booking, old_date)
        NotifyEmail::CandidateVirtualExperienceBookingDateChanged.from_booking(
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

        assign_gitis_contact @booking
      end

      def check_editable
        return true if @booking.editable_date?

        render 'uneditable'
        false
      end
    end
  end
end
