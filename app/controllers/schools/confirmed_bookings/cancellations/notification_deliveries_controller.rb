module Schools
  module ConfirmedBookings
    module Cancellations
      class NotificationDeliveriesController < Schools::BaseController
        before_action :set_booking_and_placement_request

        def show
          @cancellation = @placement_request.school_cancellation
        end

        def create
          @cancellation = @placement_request.school_cancellation
          notify_candidate @cancellation
          @cancellation.sent!
          redirect_to \
            schools_booking_cancellation_notification_delivery_path(@booking)
        end

      private

        def set_booking_and_placement_request
          @booking = current_school
            .bookings
            .eager_load(:bookings_placement_request)
            .find(params[:booking_id])
          @placement_request = @booking.bookings_placement_request
        end

        def notify_candidate(cancellation)
        # NotifyEmail::CandidateRequestRejection.new(
        #   to: cancellation.candidate_email,
        #   school_name: cancellation.school_name,
        #   candidate_name: cancellation.candidate_name,
        #   rejection_reasons: cancellation.reason,
        #   extra_details: cancellation.extra_details,
        #   dates_requested: cancellation.dates_requested,
        #   school_search_url: new_candidates_school_search_url
        # ).despatch_later!
        end
      end
    end
  end
end
