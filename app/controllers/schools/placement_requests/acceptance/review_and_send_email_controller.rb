module Schools
  module PlacementRequests
    module Acceptance
      class ReviewAndSendEmailController < Schools::BaseController
        include Acceptance
        before_action :ensure_previous_step_complete

        def new
          @review_and_send_email = Schools::PlacementRequests::ReviewAndSendEmail.new
        end

        def create
          @review_and_send_email = Schools::PlacementRequests::ReviewAndSendEmail.new(review_and_send_email_params)

          return render :new if @review_and_send_email.invalid?

          if @placement_request.booking.update(review_and_send_email_params)
            redirect_to new_schools_placement_request_acceptance_preview_confirmation_email_path(@placement_request.id)
          else
            render :new
          end
        end

      private

        def review_and_send_email_params
          params.require(:schools_placement_requests_review_and_send_email).permit(:candidate_instructions)
        end

        def ensure_previous_step_complete
          unless @placement_request.booking.more_details_added?
            redirect_to new_schools_placement_request_acceptance_add_more_details_path(@placement_request.id)
          end
        end
      end
    end
  end
end
