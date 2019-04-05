module Schools
  module PlacementRequests
    class UpcomingController < Schools::BaseController
      def index
        @placement_requests = placement_requests
      end

    private

      def placement_requests
        Array.new(
          5,
          OpenStruct.new(
            dates_requested: 'Any time during July 2019',
            received_on: '01 January 2019',
            teaching_stage: "I've applied for teacher training",
            teaching_subject: 'Maths',
            status: 'New',
            candidate: Bookings::Gitis::CRM.new('abc123').find(1)
          )
        )
      end
    end
  end
end
