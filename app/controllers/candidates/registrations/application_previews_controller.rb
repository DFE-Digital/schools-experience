module Candidates
  module Registrations
    class ApplicationPreviewsController < RegistrationsController
      def show
        @application_preview = ApplicationPreview.new \
          account_check: current_registration.fetch(AccountCheck),
          placement_preference: current_registration.fetch(PlacementPreference),
          address: current_registration.fetch(Address),
          subject_preference: current_registration.fetch(SubjectPreference),
          background_check: current_registration.fetch(BackgroundCheck)
      end
    end
  end
end
