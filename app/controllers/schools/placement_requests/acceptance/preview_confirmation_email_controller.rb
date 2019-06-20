module Schools
  module PlacementRequests
    module Acceptance
      class PreviewConfirmationEmailController < Schools::BaseController
        include Schools::RestrictAccessUnlessOnboarded
        before_action :set_placement_request
        before_action :fetch_gitis_contact_for_placement_request
        before_action :ensure_previous_step_complete

        def new; end

        def create
          booking = @placement_request.booking

          if booking.update(accepted_at: Time.now) && candidate_booking_notification(booking).despatch_later!
            redirect_to schools_placement_requests_path
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
            .from_booking(booking.candidate_email, booking.candidate_name, booking)
        end

        def set_placement_request
          @placement_request = @current_school
            .bookings_placement_requests
            .find(params[:placement_request_id])
        end

        def fetch_gitis_contact_for_placement_request
          @placement_request.fetch_gitis_contact gitis_crm
        end
      end
    end
  end
end
