module Schools
  module PlacementRequests
    module Acceptance
      class ReviewAndSendEmailController < Schools::BaseController
        before_action :set_placement_request

        def new
          @booking = @placement_request.booking
        end

        def create; end

      private

        def set_placement_request
          @placement_request = @current_school
            .bookings_placement_requests
            .find(params[:placement_request_id])
        end
      end
    end
  end
end
