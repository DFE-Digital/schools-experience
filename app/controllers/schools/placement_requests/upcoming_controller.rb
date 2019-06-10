module Schools
  module PlacementRequests
    class UpcomingController < PlacementRequestsController
      def index
        # FIXME limit to upcoming PRs
        @placement_requests = @current_school.bookings_placement_requests.all
      end
    end
  end
end
