module Schools
  class ArchivedPlacementRequestsController < BaseController
    def index
      @placement_requests = placement_requests
      assign_gitis_contacts(@placement_requests)
    end

  private

    def placement_requests
      current_school
      .placement_requests
      .unprocessed
      .old_expired_requests
      .eager_load(:candidate, :candidate_cancellation, :school_cancellation, :placement_date, :booking, :subject)
      .order(created_at: 'desc')
      .page(params[:page])
    end
  end
end
