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

      set_latest_service_update
    end

  private

    def set_latest_service_update
      @latest_service_update = ServiceUpdate.latest

      @viewed_latest_service_update =
        !!(service_update_cookie && service_update_cookie >= @latest_service_update.to_param)
    end

    def service_update_cookie
      cookies[ServiceUpdate.cookie_key]
    end
  end
end
