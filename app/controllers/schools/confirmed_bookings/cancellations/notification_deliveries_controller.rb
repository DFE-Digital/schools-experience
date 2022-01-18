module Schools
  module ConfirmedBookings
    module Cancellations
      class NotificationDeliveriesController < Schools::BaseController
        before_action :set_booking_and_placement_request

        def show
          @cancellation = @placement_request.school_cancellation
          assign_gitis_contact @placement_request
        end

        def create
          @cancellation = @placement_request.school_cancellation
          assign_gitis_contact @placement_request

          if @cancellation.sent!
            notify_candidate @cancellation

            Bookings::Gitis::SchoolExperience.from_cancellation(@cancellation, :cancelled_by_school)
              .write_to_gitis_contact(@cancellation.contact_uuid)
          end

          redirect_to \
            schools_booking_cancellation_notification_delivery_path(@booking)
        end

      private

        def set_booking_and_placement_request
          @booking = current_school
            .bookings
            .eager_load(bookings_placement_request: :candidate)
            .find(params[:booking_id])
          @placement_request = @booking.bookings_placement_request
        end

        def notify_candidate(cancellation)
          NotifyEmail::CandidateBookingSchoolCancelsBooking.new(
            to: cancellation.candidate_email,
            school_name: cancellation.school_name,
            candidate_name: cancellation.candidate_name,
            rejection_reasons: cancellation.reason,
            extra_details: cancellation.extra_details,
            dates_requested: cancellation.dates_requested,
            school_search_url: new_candidates_school_search_url
          ).despatch_later!

          NotifySms::CandidateBookingSchoolCancelsBooking.new(
            to: cancellation.gitis_contact.telephone,
            school_name: cancellation.school_name,
            dates_requested: cancellation.dates_requested,
          ).despatch_later!
        end
      end
    end
  end
end
