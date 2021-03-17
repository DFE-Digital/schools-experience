module Schools
  class OrganisationAccessRequestsController < BaseController
    skip_before_action :ensure_onboarded

    def show
      @dfe_sign_in_request_organisation_url =
        Rails.application.config.x.dfe_sign_in_request_organisation_url.presence
    end
  end
end
