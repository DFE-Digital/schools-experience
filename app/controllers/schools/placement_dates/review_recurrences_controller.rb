module Schools
  module PlacementDates
    class ReviewRecurrencesController < BaseController
      include Wizard

      before_action :set_placement_date

      def new
        @selected_dates = recurrences_session[:recurrences]

        start_date = @placement_date.date + 1.day
        end_date = (start_date + 5.months).end_of_month

        @dates_by_month = (start_date..end_date)
          .to_a
          .select(&:on_weekday?)
          .group_by { |date| date.to_formatted_s(:govuk_month_only) }
          .to_a
      end

      def create
        recurrences_session[:recurrences] = recurring_dates
        next_step(@placement_date, :review_recurrences)
      end

    private

      def recurring_dates
        params[:dates].map(&:to_date)
      end

      def set_placement_date
        @placement_date = \
          current_school.bookings_placement_dates.find(params[:placement_date_id])
      end
    end
  end
end
