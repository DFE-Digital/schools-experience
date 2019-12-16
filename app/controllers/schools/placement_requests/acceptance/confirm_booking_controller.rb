module Schools
  module PlacementRequests
    module Acceptance
      class ConfirmBookingController < Schools::BaseController
        include Acceptance

        def new
          set_placement_request
          @placement_request.fetch_gitis_contact gitis_crm
          @booking = find_or_create_booking(@placement_request)
          @last_booking = Bookings::Booking.last_accepted_booking_by(@placement_request.school)
        end

        def create
          set_placement_request
          booking.populate_contact_details!

          if booking.save
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
