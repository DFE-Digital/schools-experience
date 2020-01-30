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
      @withdrawn_request.fetch_gitis_contact gitis_crm

      @cancellation = @withdrawn_request.candidate_cancellation
      @cancellation.viewed!
    end

  private

    def scope
      current_school.placement_requests.withdrawn
    end
  end
end
