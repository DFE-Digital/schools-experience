module Schools
  module PlacementRequests
    class CancellationsController < Schools::BaseController
      before_action :set_placement_request
      before_action :ensure_placement_request_is_open

      def show
        @cancellation = @placement_request.school_cancellation
        @placement_request.fetch_gitis_contact gitis_crm
      end

      def new
        @cancellation = @placement_request.build_school_cancellation
        @placement_request.fetch_gitis_contact gitis_crm
      end

      def create
        @cancellation = @placement_request.build_school_cancellation \
          cancellation_params

        @placement_request.fetch_gitis_contact gitis_crm

        if @cancellation.save(context: :rejection)
          redirect_to schools_placement_request_cancellation_path \
            @placement_request
        else
          render :new
        end
      end

      def edit
        @cancellation = @placement_request.school_cancellation
        @placement_request.fetch_gitis_contact gitis_crm
      end

      def update
        @cancellation = @placement_request.school_cancellation
        @cancellation.assign_attributes(cancellation_params)

        if @cancellation.save(context: :rejection)
          redirect_to schools_placement_request_cancellation_path \
            @placement_request
        else
          @placement_request.fetch_gitis_contact gitis_crm
          render :edit
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

      def cancellation_params
        params.require(:bookings_placement_request_cancellation).permit \
          :rejection_category, :reason, :extra_details
      end
    end
  end
end
