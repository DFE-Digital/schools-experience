module Schools
  class DashboardsController < BaseController
    skip_before_action :ensure_onboarded

    def show
      @school = current_school

      summary = OutstandingTasks.new([current_school.urn]).summarize
      @outstanding_tasks = summary[current_school.urn]

      @dfe_sign_in_request_organisation_url =
        Rails.application.config.x.dfe_sign_in_request_organisation_url.presence
    end

  end
end
