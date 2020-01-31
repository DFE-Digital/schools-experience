module Schools
  module PlacementRequests
    module Acceptance
      class PreviewConfirmationEmailController < Schools::BaseController
        include Acceptance

        def edit
          set_placement_request_and_fetch_gitis_contact

          @booking = @placement_request.booking
        end

        def update
          set_placement_request_and_fetch_gitis_contact

          @booking = @placement_request.booking
          @booking.assign_attributes(booking_params)

          if @booking.valid?(:acceptance_email_preview) && @booking.accept! && candidate_booking_notification(@booking).despatch_later!

            redirect_to schools_placement_request_acceptance_email_sent_path(@placement_request.id)
          else
            render :edit
          end
        end

      private

        def booking_params
          params.require(:bookings_booking).permit(:candidate_instructions)
        end

        def candidate_booking_notification(booking)
          NotifyEmail::CandidateBookingConfirmation
            .from_booking(booking.candidate_email, booking.candidate_name, booking, candidates_cancel_url(booking.token))
        end
      end
    end
  end
end
