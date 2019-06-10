module Schools
  module PlacementRequests
    class UpcomingController < PlacementRequestsController
      def index
        @placement_requests = placement_requests.open
      end
    end
  end
end
