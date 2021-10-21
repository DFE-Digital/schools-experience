module Schools
  module PlacementRequests
    class UnderConsiderationController < Schools::BaseController

      def place_under_consideration
        placement_request = current_school.placement_requests.find params[:placement_request_id]

        placement_request.place_under_consideration

        redirect_to schools_placement_requests_path
      end
    end
  end
end
