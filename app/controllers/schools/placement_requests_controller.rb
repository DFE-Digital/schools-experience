module Schools
  class PlacementRequestsController < Schools::BaseController
    def index
      @placement_requests = @current_school.bookings_placement_requests.all
    end

    def show
      @placement_request = @current_school.bookings_placement_requests.find(params[:id])
    end
  end
end
