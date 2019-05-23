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
        registration_session = RegistrationStore.instance.retrieve! params[:uuid]

        unless registration_session.completed?
          Bookings::PlacementRequest.create_from_registration_session! \
            registration_session

          registration_session.flag_as_completed!

          RegistrationStore.instance.store! registration_session

          PlacementRequestJob.perform_later registration_session.uuid
        end

        redirect_to candidates_school_registrations_placement_request_path \
          registration_session.school,
          uuid: registration_session.uuid
      rescue RegistrationStore::SessionNotFound
        render :session_expired
      end
    end
  end
end
