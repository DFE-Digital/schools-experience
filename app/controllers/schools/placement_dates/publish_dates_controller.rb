module Schools
  module PlacementDates
    class PublishDatesController < BaseController
      include Wizard

      before_action :set_placement_date, :set_dates

      def new; end

      def create
        next_step(@placement_date, :publish_dates)
      end

    private

      def set_dates
        @dates = if @placement_date.recurring? && !@placement_date.published?
                   recurrences_session[:confirmed_recurrences]
                 else
                   [@placement_date.date]
                 end
      end

      def set_placement_date
        @placement_date = \
          current_school.bookings_placement_dates.find(params[:placement_date_id])
      end
    end
  end
end
