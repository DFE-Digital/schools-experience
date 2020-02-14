module Schools
  class DashboardsController < BaseController
    skip_before_action :ensure_onboarded

    def show
      @school = current_school

      @requests_requiring_attention = current_school
        .placement_requests
        .requiring_attention
        .count

      @bookings_requiring_attention = current_school
        .bookings
        .with_unviewed_candidate_cancellation
        .count

      @candidate_attendances = current_school
        .bookings
        .previous
        .not_cancelled
        .accepted
        .attendance_unlogged
        .count

      @withdrawn_requests = current_school
        .placement_requests
        .withdrawn_but_unviewed
        .count

      @latest_service_update = ServiceUpdate.latest
    end
  end
end
