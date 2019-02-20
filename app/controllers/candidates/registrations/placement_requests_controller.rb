module Candidates
  module Registrations
    class PlacementRequestsController < RegistrationsController
      def show
        registration_session = RegistrationStore.instance.retrieve! params[:uuid]
        @application_preview = ApplicationPreview.new registration_session
      rescue RegistrationStore::SessionNotFound
        render :session_expired, locals: { message: 'Start a new application' }
      end

      def create
        uuid = params[:uuid]
        if RegistrationStore.instance.has_registration? uuid
          PlacementRequestJob.perform_later uuid
          redirect_to \
            candidates_school_registrations_placement_request_path uuid: uuid
        else
          render :session_expired
        end
      end
    end
  end
end
