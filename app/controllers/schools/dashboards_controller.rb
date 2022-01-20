module Schools
  class DashboardsController < BaseController
    skip_before_action :ensure_onboarded

    def show
      @school = current_school

      summary = OutstandingTasks.new([current_school.urn]).summarize
      @outstanding_tasks = summary[current_school.urn]

      set_latest_service_update

      @dfe_sign_in_request_organisation_url =
        Rails.application.config.x.dfe_sign_in_request_organisation_url.presence
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
