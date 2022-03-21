module Schools
  module PlacementDates
    class RecurrencesSelectionsController < BaseController
      include Wizard

      before_action :set_placement_date

      def new
        @recurrences_selection = RecurrencesSelection.new_from_date(@placement_date)
      end

      def create
        @recurrences_selection = RecurrencesSelection.new(recurrences_selection_params)

        if @recurrences_selection.valid?
          recurrences_session[:recurrences] = @recurrences_selection.recurring_dates

          next_step(@placement_date, :recurrences_selection)
        else
          render :new
        end
      end

    private

      def set_placement_date
        @placement_date = \
          current_school.bookings_placement_dates.find(params[:placement_date_id])
      end

      def recurrences_selection_params
        params.require(:schools_placement_dates_recurrences_selection).permit \
          :start_at, :end_at, :recurrence_period, custom_recurrence_days: []
      end
    end
  end
end
