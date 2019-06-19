module Schools
  module PlacementRequests
    class UpcomingController < PlacementRequestsController
      include Schools::RestrictAccessUnlessOnboarded

      def index
        @placement_requests = placement_requests.open
      end
    end
  end
end
