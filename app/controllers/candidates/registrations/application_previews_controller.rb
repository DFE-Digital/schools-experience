module Candidates
  module Registrations
    class ApplicationPreviewsController < RegistrationsController
      def show
        @application_preview = ApplicationPreview.new current_registration
      end
    end
  end
end
