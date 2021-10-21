module Schools
  module PlacementRequests
    class UnderConsiderationController < Schools::BaseController
      def place_under_consideration
        placement_request = current_school.placement_requests.find params[:placement_request_id]
        placement_request.update(under_consideration_at: Time.zone.now) unless placement_request.under_consideration?
        redirect_to schools_placement_requests_path
      rescue ActiveRecord::RecordNotFound
        render :'errors/not_found', status: :not_found
      end
    end
  end
end
