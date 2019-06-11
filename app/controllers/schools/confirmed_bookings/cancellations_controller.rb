module Schools
  module ConfirmedBookings
    class CancellationsController < Schools::BaseController
      before_action :set_booking_and_placement_request

      def show
        @cancellation = @placement_request.school_cancellation
      end

      def new
        @cancellation = @placement_request.build_school_cancellation
      end

      def edit
        @cancellation = @placement_request.school_cancellation
      end

      def create
        @cancellation = @placement_request.build_school_cancellation \
          cancellation_params

        if @cancellation.save
          redirect_to schools_booking_cancellation_path \
            @booking
        else
          render :new
        end
      end

      def update
        @cancellation = @placement_request.school_cancellation

        if @cancellation.update cancellation_params
          redirect_to schools_booking_cancellation_path \
            @booking
        else
          render :edit
        end
      end

    private

      def set_booking_and_placement_request
        @booking = current_school
          .bookings
          .eager_load(:bookings_placement_request)
          .find(params[:booking_id])
        @placement_request = @booking.bookings_placement_request
      end

      def cancellation_params
        params.require(:bookings_placement_request_cancellation).permit \
          :reason, :extra_details
      end
    end
  end
end
