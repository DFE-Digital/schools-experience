module Schools
  module RestrictAccessUnlessOnboarded
    extend ActiveSupport::Concern

    included do
      before_action :ensure_onboarded
    end

  private

    def ensure_onboarded
      unless @current_school.private_beta?
        Rails.logger.warn("%<school_name>s tried to access %<page>s before completing profile" % {
          school_name: @current_school.name,
          page: request.path
        })

        redirect_to schools_dashboard_path
      end
    end
  end
end
