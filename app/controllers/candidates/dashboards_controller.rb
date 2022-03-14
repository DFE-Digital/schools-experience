class Candidates::DashboardsController < Candidates::DashboardBaseController
  def show
    @placement_requests =
      current_candidate
        .placement_requests
        .eager_load(:candidate_cancellation, :school_cancellation, :placement_date, [booking: :candidate_feedback], :subject, :school)
        .order(created_at: 'desc')
        .page(params[:page])
        .per(15)
  end
end
