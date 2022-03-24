module Schools
  module PlacementDates
    class ReviewRecurrencesController < BaseController
      include Wizard

      before_action :set_placement_date, :set_dates_by_month

      def new
        @review_recurrences = ReviewRecurrences.new(dates: recurring_dates_session)
      end

      def create
        @review_recurrences = ReviewRecurrences.new(dates: recurring_dates_string_param.split(", "))

        if @review_recurrences.valid?
          recurrences_session[:confirmed_recurrences] = @review_recurrences.dates
          next_step(@placement_date, :review_recurrences)
        else
          render :new
        end
      end

    private

      def set_dates_by_month
        @dates_by_month = recurring_dates_session
          .group_by { |date| date.to_formatted_s(:govuk_month_only) }
          .to_a
      end

      def recurring_dates_session
        recurrences_session[:recurrences]
      end

      def recurring_dates_param
        params.dig(:schools_placement_dates_review_recurrences, :dates) || []
      end

      def recurring_dates_string_param
        params.dig(:schools_placement_dates_review_recurrences, :dates_as_string) || []
      end

      def set_placement_date
        @placement_date = \
          current_school.bookings_placement_dates.find(params[:placement_date_id])
      end
    end
  end
end
