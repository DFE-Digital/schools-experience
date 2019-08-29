module Schools
  module PlacementRequests
    module Acceptance
      class PreviewConfirmationEmailController < Schools::BaseController
        include Acceptance
        before_action :ensure_previous_step_complete

        def new; end

        def create
          booking = @placement_request.booking

          if booking.update(accepted_at: Time.zone.now) && candidate_booking_notification(booking).despatch_later!
            Bookings::Gitis::EventLogger.write_later \
              booking.contact_uuid, :booking, booking

            redirect_to schools_placement_request_acceptance_email_sent_path(@placement_request.id)
          else
            render :new
          end
        end

      private

        def ensure_previous_step_complete
          unless @placement_request.booking.reviewed_and_candidate_instructions_added?
            redirect_to new_schools_placement_request_acceptance_add_more_details_path(@placement_request.id)
          end
        end

        def candidate_booking_notification(booking)
          NotifyEmail::CandidateBookingConfirmation
            .from_booking(booking.candidate_email, booking.candidate_name, booking, candidates_cancel_url(booking.token))
        end
      end
    end
  end
end
