module Schools
  module PlacementDates
    class DateLimitsController < BaseController
      before_action :set_placement_date

      def new
        @date_limit = DateLimitForm.new_from_date @placement_date
      end

      def create
        @date_limit = DateLimitForm.new form_params
        @date_limit.assign_attributes form_params

        if @date_limit.save @placement_date
          redirect_to schools_placement_dates_path
        else
          render 'new'
        end
      end

    private

      def set_placement_date
        @placement_date = \
          current_school.bookings_placement_dates.find params[:placement_date_id]
      end

      def form_key
        DateLimitForm.model_name.param_key
      end

      def form_params
        params.require(form_key).permit(:max_bookings_count)
      end
    end
  end
end
