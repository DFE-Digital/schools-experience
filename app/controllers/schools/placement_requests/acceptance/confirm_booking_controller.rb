module Schools
  module PlacementRequests
    module Acceptance
      class ConfirmBookingController < Schools::BaseController
        include Acceptance

        def new
          set_placement_request_and_fetch_gitis_contact

          @placement_request.fetch_gitis_contact gitis_crm
          @booking = find_or_build_booking(@placement_request)
          @last_booking_found = @booking.populate_contact_details
        end

        def create
          @placement_request = @current_school
            .bookings_placement_requests
            .find(params[:placement_request_id])

          booking = find_or_build_booking(@placement_request)

          if booking.save(context: :acceptance)
            redirect_to edit_schools_placement_request_acceptance_preview_confirmation_email_path(@placement_request.id)
          else
            @placement_request.fetch_gitis_contact gitis_crm
            render :new
          end
        end
      end
    end
  end
end
