module Schools
  module PlacementRequests
    module Acceptance
      class ConfirmBookingController < Schools::BaseController
        before_action :set_placement_request, :set_available_subjects

        def new
          @booking = Bookings::Booking.new
        end

        def create
          # FIXME check of there's already a booking
          @booking = Bookings::Booking.new(bookings_booking_params)

          if @booking.save
            redirect_to new_schools_placement_request_acceptance_add_more_details_path(@placement_request.id)
          else
            render :new
          end
        end

      private

        def bookings_booking_params
          params
            .require(:bookings_booking)
            .permit(:bookings_subject_id, :date, :placement_details)
            .merge(
              bookings_placement_request_id: @placement_request.id,
              bookings_school_id: @current_school.id
            )
        end

        def set_placement_request
          @placement_request = @current_school
            .bookings_placement_requests
            .find(params[:placement_request_id])
        end

        def set_available_subjects
          school_subjects = @current_school.subjects
          @available_subjects = (school_subjects&.any? && school_subjects) || Bookings::Subject.all
        end
      end
    end
  end
end
