module Schools
  module PlacementRequests
    module Acceptance
      class EmailSentController < Schools::BaseController
        before_action :set_placement_request
        before_action :fetch_gitis_contact_for_placement_request
        before_action :ensure_previous_step_complete

        def show; end

      private

        def ensure_previous_step_complete
          unless @placement_request.booking.accepted?
            redirect_to new_schools_placement_request_acceptance_review_and_send_email_path(@placement_request.id)
          end
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
