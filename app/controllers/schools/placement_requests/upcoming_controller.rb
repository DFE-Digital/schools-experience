module Schools
  module PlacementRequests
    class UpcomingController < PlacementRequestsController
      def index
        @placement_requests = placement_requests.open
        assign_gitis_contacts @placement_requests
      end
    end
  end
end
