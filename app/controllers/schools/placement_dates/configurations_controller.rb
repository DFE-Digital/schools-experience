module Schools
  module PlacementDates
    class ConfigurationsController < BaseController
      include Wizard

      before_action :set_placement_date

      def new
        @configuration = ConfigurationForm.new_from_date @placement_date
      end

      def create
        @configuration = ConfigurationForm.new configuration_params
        @configuration.supports_subjects = @placement_date.supports_subjects

        if @configuration.save @placement_date
          next_step @placement_date, :configuration
        else
          render :new
        end
      end

    private

      def set_placement_date
        @placement_date = \
          current_school.bookings_placement_dates.find params[:placement_date_id]
      end

      def configuration_params
        params.require(:schools_placement_dates_configuration_form).permit(
          :has_limited_availability,
          :max_bookings_count,
          :available_for_all_subjects
        )
      end
    end
  end
end
