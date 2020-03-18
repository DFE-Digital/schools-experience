module Schools
  class WithdrawnRequestsController < Schools::BaseController
    def index
      @requests = scope
        .includes(:candidate, :candidate_cancellation, placement_date: :subjects)
        .page(params[:page])

      assign_gitis_contacts @requests
    end

    def show
      @withdrawn_request = scope.find(params[:id])
      assign_gitis_contact @withdrawn_request

      @cancellation = @withdrawn_request.candidate_cancellation
      @cancellation.viewed!
    end

  private

    def scope
      current_school.placement_requests.withdrawn
    end
  end
end
