module Schools
  class ContactUsController < BaseController
    skip_before_action :ensure_onboarded, :require_auth, :set_current_school

    def show
      @signed_in = user_signed_in?
    end
  end
end
