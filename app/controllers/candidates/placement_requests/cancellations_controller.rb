module Candidates
  module PlacementRequests
    class CancellationsController < ApplicationController
      before_action :set_placement_request
      before_action :ensure_placement_request_is_open, except: :show

      def show
        @cancellation = @placement_request.cancellation
      end

      def new
        @cancellation = @placement_request.build_cancellation
      end

      def create
        @cancellation = @placement_request.build_cancellation \
          placement_request_params

        if @cancellation.save
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
          # FIXME redirect to candidate's placment request dashboard if the
          # the placement request is closed.
          # For the time being we're redirecting to cancellation#show
          # as that's the currenlty the only way a placement request can be
          # 'closed'.
          redirect_to candidates_placement_request_cancellation_path \
            @placement_request.token
        end
      end
    end
  end
end
