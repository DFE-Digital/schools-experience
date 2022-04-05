class Candidates::DashboardsController < Candidates::DashboardBaseController
  def show
    @placement_requests =
      ::Bookings::PlacementRequest.where(candidate: current_candidate)
      .includes(:booking, :placement_date, :subject, :candidate_cancellation, :school_cancellation)
      .order(created_at: 'desc')
      .page(params[:page])
      .per(15)
  end
end
