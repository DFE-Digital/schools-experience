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
            log_to_gitis booking
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

        def log_to_gitis(booking)
          Bookings::LogToGitisJob.perform_later \
            booking.contact_uuid,
            booking.accepted_at.to_date.strftime('%d/%m/%Y'),
            'CONFIRMED',
            booking.date.strftime('%d/%m/%Y'), # return nil for flexible dates
            booking.bookings_school.urn,
            booking.bookings_school.name
        end
      end
    end
  end
end
