module Schools
  class ContactUsController < BaseController
    skip_before_action :ensure_onboarded

    def show
      @school = current_school
    end
  end
end
