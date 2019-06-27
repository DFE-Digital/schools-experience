module Schools
  module PlacementRequests
    module Acceptance
      class EmailSentController < Schools::BaseController
        include Acceptance
        before_action :ensure_previous_step_complete

        def show; end

      private

        def ensure_previous_step_complete
          unless @placement_request.booking.accepted?
            redirect_to new_schools_placement_request_acceptance_review_and_send_email_path(@placement_request.id)
          end
        end
      end
    end
  end
end
