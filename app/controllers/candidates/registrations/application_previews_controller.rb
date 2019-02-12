module Candidates
  module Registrations
    class ApplicationPreviewsController < RegistrationsController
      def show
        @application_preview = ApplicationPreview.new \
          account_check: current_registration.account_check,
          placement_preference: current_registration.placement_preference,
          address: current_registration.address,
          subject_preference: current_registration.subject_preference,
          background_check: current_registration.background_check
      end
    end
  end
end
