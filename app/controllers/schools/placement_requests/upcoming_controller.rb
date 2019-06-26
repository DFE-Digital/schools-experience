module Schools
  module PlacementRequests
    class UpcomingController < PlacementRequestsController
      include Schools::RestrictAccessUnlessOnboarded

      def index
        @placement_requests = placement_requests.open
        assign_gitis_contacts @placement_requests
      end
    end
  end
end
