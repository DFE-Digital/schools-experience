module Schools
  module PlacementRequests
    module Acceptance
      class ReviewAndSendEmailController < Schools::BaseController
        before_action :set_placement_request
        before_action :ensure_previous_step_complete

        def new
          @review_and_send_email = Schools::PlacementRequests::ReviewAndSendEmail.new
        end

        def create
          @review_and_send_email = Schools::PlacementRequests::ReviewAndSendEmail.new(review_and_send_email_params)

          return render :new if @review_and_send_email.invalid?

          booking = @placement_request.booking
          booking.candidate_instructions = @review_and_send_email.candidate_instructions

          if booking.save && candidate_booking_notification(booking).despatch_later!
            redirect_to schools_placement_requests_path
          else
            render :new
          end
        end

      private

        def candidate_booking_notification(booking)
          NotifyEmail::CandidateBookingConfirmation
            .from_booking(booking.candidate.email, booking)
        end

        def review_and_send_email_params
          params.require(:review_and_send_email).permit(:candidate_instructions)
        end

        def ensure_previous_step_complete
          unless @placement_request.booking.more_details_added?
            redirect_to new_schools_placement_request_acceptance_add_more_details_path(@placement_request.id)
          end
        end

        def set_placement_request
          @placement_request = @current_school
            .bookings_placement_requests
            .find(params[:placement_request_id])
        end
      end
    end
  end
end
