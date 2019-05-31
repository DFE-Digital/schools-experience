module Schools
  module PlacementRequests
    module Acceptance
      class AddMoreDetailsController < Schools::BaseController
        before_action :set_placement_request

        def new
          @booking = @placement_request.booking
        end

        def create
          @booking = @placement_request.booking

          if @booking.update(booking_params)
            redirect_to new_schools_placement_request_acceptance_review_and_send_email_path(@placement_request.id)
          else
            render :new
          end
        end

      private

        def set_placement_request
          @placement_request = @current_school
            .bookings_placement_requests
            .find(params[:placement_request_id])
        end

        def booking_params
          params.require(:bookings_booking).permit(
            :contact_name,
            :contact_number,
            :contact_email,
            :location
          )
        end
      end
    end
  end
end
