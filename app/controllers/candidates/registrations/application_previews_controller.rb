module Candidates
  module Registrations
    class ApplicationPreviewsController < RegistrationsController
      def show
        @application_preview = ApplicationPreview.new current_registration
        @privacy_policy = PrivacyPolicy.new
      end
    end
  end
end
