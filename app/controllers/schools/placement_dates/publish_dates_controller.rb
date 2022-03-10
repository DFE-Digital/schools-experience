module Schools
  module PlacementDates
    class PublishDatesController < BaseController
      include Wizard

      before_action :set_placement_date

      def new; end

      def create
        next_step(@placement_date, :publish_dates)
      end

    private

      def set_placement_date
        @placement_date = \
          current_school.bookings_placement_dates.find(params[:placement_date_id])
      end
    end
  end
end
