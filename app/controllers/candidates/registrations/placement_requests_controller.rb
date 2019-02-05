module Candidates
  module Registrations
    class PlacementRequestsController < RegistrationsController
      PlacementRequest = Struct.new \
        :status_in_words,
        :date_range_in_words,
        :school_name

      def show
        @placement_request = PlacementRequest.new \
          "sent",
          "from 8 to 12 October 2018",
          "Abraham Moss Community School"
      end

      def create
        redirect_to candidates_registrations_placement_request_path
      end
    end
  end
end
