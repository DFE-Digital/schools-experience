module Schools
  module PlacementRequests
    module Acceptance
      class ConfirmBookingController < Schools::BaseController
        include Acceptance
        before_action :set_available_subjects

        def new
          @confirm_booking = Schools::PlacementRequests::ConfirmBooking.new(
            bookings_subject_id: @placement_request.requested_subject.id,
            date: @placement_request.placement_date&.date,
            placement_details: @current_school&.profile&.experience_details
          )
          @placement_request.fetch_gitis_contact gitis_crm
        end

        def create
          @confirm_booking = Schools::PlacementRequests::ConfirmBooking.new(confirm_booking_params)

          if @confirm_booking.invalid?
            @placement_request.fetch_gitis_contact gitis_crm
            return render :new
          end

          booking = find_or_create_booking(@placement_request)

          if booking.save
            redirect_to new_schools_placement_request_acceptance_add_more_details_path(@placement_request.id)
          else
            @placement_request.fetch_gitis_contact gitis_crm
            Rails.logger.warn("ConfirmBooking was valid but Booking wasn't: #{params}")
            render :new
          end
        end

      private

        def find_or_create_booking(placement_request)
          duration = placement_request&.placement_date&.duration

          placement_request.booking || Bookings::Booking.from_confirm_booking(@confirm_booking).tap do |booking|
            booking.bookings_placement_request = placement_request
            booking.bookings_school = @current_school
            (booking.duration = duration) if duration
          end
        end

        def confirm_booking_params
          params
            .require(:schools_placement_requests_confirm_booking)
            .permit(:bookings_subject_id, :date, :placement_details)
        end

        def set_available_subjects
          school_subjects = @current_school.subjects
          @available_subjects = (school_subjects&.any? && school_subjects) || Bookings::Subject.available
        end
      end
    end
  end
end
