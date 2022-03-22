module Schools
  class RejectedRequestsController < Schools::BaseController
    def index
      @requests = scope
        .includes(:candidate, :school_cancellation, :subject, placement_date: :subjects)
        .page(params[:page])
        .per(50)

      assign_gitis_contacts @requests
    end

    def show
      @rejected_request = scope.find(params[:id])
      assign_gitis_contact @rejected_request

      @cancellation = @rejected_request.school_cancellation
    end

  private

    def scope
      current_school.placement_requests.rejected
    end
  end
end
