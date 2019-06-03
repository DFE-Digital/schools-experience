module Schools
  module PlacementRequests
    module Acceptance
      class ConfirmBookingController < Schools::BaseController
        before_action :set_placement_request, :set_available_subjects

        def new
          @confirm_booking = Schools::PlacementRequests::ConfirmBooking.new
        end

        def create
          @confirm_booking = Schools::PlacementRequests::ConfirmBooking.new(confirm_booking_params)

          return render :new if @confirm_booking.invalid?

          booking = find_or_create_booking(@placement_request)

          if booking.save
            redirect_to new_schools_placement_request_acceptance_add_more_details_path(@placement_request.id)
          else
            Rails.logger.warn("ConfirmBooking was valid but Booking wasn't: #{params}")
            render :new
          end
        end

      private

        def find_or_create_booking(placement_request)
          placement_request.booking || Bookings::Booking.from_confirm_booking(@confirm_booking).tap do |booking|
            booking.bookings_placement_request = placement_request
            booking.bookings_school = @current_school
          end
        end

        def confirm_booking_params
          params
            .require(:confirm_booking)
            .permit(:bookings_subject_id, :date, :placement_details)
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
