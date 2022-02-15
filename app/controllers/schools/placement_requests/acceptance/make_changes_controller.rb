module Schools
  module PlacementRequests
    module Acceptance
      class MakeChangesController < Schools::BaseController
        include Acceptance

        def new
          set_placement_request_and_fetch_gitis_contact

          @booking = @placement_request.booking || Bookings::Booking.from_placement_request(@placement_request)
          @booking.populate_contact_details

          @subjects = @current_school.subjects.all
        end

        def create
          set_placement_request_and_fetch_gitis_contact

          @booking = find_or_build_booking(@placement_request)
          @booking.assign_attributes(booking_params)

          if @booking.save(context: :acceptance)
            redirect_to edit_schools_placement_request_acceptance_preview_confirmation_email_path(@placement_request.id)
          else
            @subjects = @current_school.subjects.all

            render :new
          end
        end

      private

        def booking_params
          params.require(:bookings_booking).permit(
            :date,
            :duration,
            :bookings_subject_id,
            :contact_name,
            :contact_number,
            :contact_email
          )
        end
      end
    end
  end
end
