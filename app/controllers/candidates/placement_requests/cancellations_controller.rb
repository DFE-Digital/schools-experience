module Candidates
  module PlacementRequests
    class CancellationsController < ApplicationController
      include GitisAccess
      before_action :ensure_placement_request_is_open, except: :show

      def show
        @cancellation = placement_request.cancellation
      end

      def new
        @cancellation = placement_request.build_candidate_cancellation
      end

      def create
        @cancellation = placement_request.build_candidate_cancellation \
          placement_request_params

        if @cancellation.save(context: :candidate_cancellation)
          assign_gitis_contact @placement_request

          notify_school @cancellation
          notify_candidate @cancellation
          @cancellation.sent!

          Bookings::Gitis::EventLogger.write_later \
            @cancellation.contact_uuid, :cancellation, @cancellation

          redirect_to candidates_placement_request_cancellation_path \
            placement_request.token
        else
          render :new
        end
      end

    private

      def placement_request_params
        params.require(:bookings_placement_request_cancellation).permit :reason
      end

      def placement_request
        @placement_request ||= \
          Bookings::PlacementRequest.find_by! token: params[:placement_request_token]
      end

      def ensure_placement_request_is_open
        if placement_request.closed?
          # FIXME SE-1097 redirect to candidate's placment request dashboard if the
          # the placement request is closed.
          # For the time being we're redirecting to cancellation#show
          # as that's the currenlty the only way a placement request can be
          # 'closed' by a candidate.
          redirect_to candidates_placement_request_cancellation_path \
            placement_request.token
        end
      end

      def notify_school(cancellation)
        if cancellation.booking.present?
          notify_school_of_booking_cancellation cancellation
        else
          notify_school_of_request_cancellation cancellation
        end
      end

      def notify_candidate(cancellation)
        if cancellation.booking.present?
          notify_candidate_of_booking_cancellation cancellation
        else
          notify_candidate_of_request_cancellation cancellation
        end
      end

      def notify_school_of_booking_cancellation(cancellation)
        NotifyEmail::SchoolBookingCancellation.new(
          to: cancellation.school_email,
          school_name: cancellation.school_name,
          candidate_name: cancellation.candidate_name,
          placement_start_date_with_duration: cancellation.booking.placement_start_date_with_duration
        ).despatch_later!
      end

      def notify_school_of_request_cancellation(cancellation)
        NotifyEmail::SchoolRequestCancellation.new(
          to: cancellation.school_email,
          school_name: cancellation.school_name,
          candidate_name: cancellation.candidate_name,
          cancellation_reasons: cancellation.reason,
          requested_on: cancellation.placement_request.requested_on.to_formatted_s(:govuk),
          placement_request_url: schools_placement_request_url(cancellation.placement_request)
        ).despatch_later!
      end

      def notify_candidate_of_booking_cancellation(cancellation)
        NotifyEmail::CandidateBookingCancellation.new(
          to: cancellation.candidate_email,
          school_name: cancellation.school_name,
          placement_start_date_with_duration: cancellation.booking.placement_start_date_with_duration,
          school_search_url: new_candidates_school_search_url
        ).despatch_later!
      end

      def notify_candidate_of_request_cancellation(cancellation)
        NotifyEmail::CandidateRequestCancellation.new(
          to: cancellation.candidate_email,
          school_name: cancellation.school_name,
          requested_availability: cancellation.dates_requested,
          school_search_url: new_candidates_school_search_url
        ).despatch_later!
      end
    end
  end
end
