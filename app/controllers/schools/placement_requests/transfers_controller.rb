module Schools
  module PlacementRequests
    class TransfersController < Schools::BaseController
      before_action :set_placement_request
      before_action :ensure_placement_request_is_open

      def new
        @transfer = Bookings::PlacementRequest::Transfer.new(
          @placement_request,
          school_uuids(reload: true)
        )
      end

      def create
        @transfer = Bookings::PlacementRequest::Transfer.new(
          @placement_request,
          school_uuids(reload: true),
          transfer_params
        )

        if @transfer.perform!
          flash.notice = "Request transferred to #{@transfer.transfer_to_school.name}"
          redirect_to schools_placement_requests_path
        else
          render :new
        end
      end

    private

      def set_placement_request
        @placement_request = \
          current_school.placement_requests.find params[:placement_request_id]
      end

      def ensure_placement_request_is_open
        if @placement_request.closed?
          redirect_to schools_placement_request_path @placement_request
        end
      end

      def transfer_params
        params
          .fetch(:bookings_placement_request_transfer, {})
          .permit(:transfer_to_urn)
      end
    end
  end
end
