module Schools
  module PlacementRequests
    module Acceptance
      class AddMoreDetailsController < Schools::BaseController
        include Acceptance
        before_action :ensure_previous_step_complete

        def new
          @add_more_details = Schools::PlacementRequests::AddMoreDetails.for_school(@current_school)
        end

        def create
          @add_more_details = Schools::PlacementRequests::AddMoreDetails.new(add_more_details_params)

          return render :new if @add_more_details.invalid?

          booking = @placement_request.booking

          booking.tap do |b|
            b.contact_name   = @add_more_details.contact_name
            b.contact_number = @add_more_details.contact_number
            b.contact_email  = @add_more_details.contact_email
            b.location       = @add_more_details.location
          end

          if booking.save
            redirect_to new_schools_placement_request_acceptance_review_and_send_email_path(@placement_request.id)
          else
            render :new
          end
        end

      private

        def ensure_previous_step_complete
          unless @placement_request.booking.booking_confirmed?
            redirect_to new_schools_placement_request_acceptance_confirm_booking_path(@placement_request.id)
          end
        end

        def add_more_details_params
          params.require(:schools_placement_requests_add_more_details).permit(
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
