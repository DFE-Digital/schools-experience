module Candidates
  module PlacementRequests
    class CancellationsController < ApplicationController
      before_action :set_placement_request
      before_action :ensure_placement_request_is_open, except: :show

      def show
        @cancellation = @placement_request.candidate_cancellation
      end

      def new
        @cancellation = @placement_request.build_candidate_cancellation
      end

      def create
        @cancellation = @placement_request.build_candidate_cancellation \
          placement_request_params

        if @cancellation.save
          notify_school @cancellation
          notify_candidate @cancellation
          redirect_to candidates_placement_request_cancellation_path \
            @placement_request.token
        else
          render :new
        end
      end

    private

      def placement_request_params
        params.require(:bookings_placement_request_cancellation).permit :reason
      end

      def set_placement_request
        @placement_request = \
          Bookings::PlacementRequest.find_by! token: params[:placement_request_token]
      end

      def ensure_placement_request_is_open
        if @placement_request.closed?
          # FIXME SE-1097 redirect to candidate's placment request dashboard if the
          # the placement request is closed.
          # For the time being we're redirecting to cancellation#show
          # as that's the currenlty the only way a placement request can be
          # 'closed'.
          redirect_to candidates_placement_request_cancellation_path \
            @placement_request.token
        end
      end

      def notify_school(cancellation)
        NotifyEmail::SchoolRequestCancellation.new(
          to: cancellation.school_email,
          school_name: cancellation.school_name,
          school_admin_name: cancellation.school_admin_name,
          candidate_name: cancellation.candidate_name,
          cancellation_reasons: cancellation.reason,
          requested_availability: cancellation.requested_availability,
          placement_request_url: schools_placement_request_url(cancellation.placement_request)
        ).despatch_later!
      end

      def notify_candidate(cancellation)
        NotifyEmail::CandidateRequestCancellation.new(
          to: cancellation.candidate_email,
          school_name: cancellation.school_name,
          candidate_name: cancellation.candidate_name,
          requested_availability: cancellation.requested_availability
        ).despatch_later!
      end
    end
  end
end
