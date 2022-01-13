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

          if @booking.valid?(:acceptance_email_preview) && @booking.accept!
            candidate_booking_notifications(@booking)

            Bookings::Gitis::SchoolExperience.from_booking(@booking, :confirmed)
              .write_to_gitis_contact(@booking.contact_uuid)

            redirect_to schools_placement_request_acceptance_email_sent_path(@placement_request.id)
          else
            render :edit
          end
        end

      private

        def booking_params
          params.require(:bookings_booking).permit(:candidate_instructions)
        end

        def candidate_booking_notifications(booking)
          NotifyEmail::CandidateBookingConfirmation
            .from_booking(booking.candidate_email, booking.candidate_name, booking, candidates_cancel_url(booking.token)).despatch_later!

          NotifySms::CandidateBookingConfirmation.new(
            to: booking.gitis_contact.telephone,
            school_name: booking.bookings_school.name,
            dates_requested: booking.date.to_formatted_s(:govuk),
            cancellation_url: candidates_cancel_url(booking.token),
          ).despatch_later!
        end
      end
    end
  end
end
