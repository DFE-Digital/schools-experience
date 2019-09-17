module Candidates
  module Registrations
    class PlacementRequestsController < RegistrationsController
      skip_before_action :ensure_step_permitted!

      def show
        @school_name = Bookings::School.find_by!(urn: params[:school_id]).name
      end

      def create
        registration_session = RegistrationStore.instance.retrieve! params[:uuid]

        unless registration_session.completed?
          registration_session.flag_as_completed!
          RegistrationStore.instance.store! registration_session

          CreatePlacementRequestJob.perform_later \
            registration_session.uuid,
            current_contact&.id,
            request.host,
            cookies[:analytics_tracking_uuid]
        end

        redirect_to candidates_school_registrations_placement_request_path \
          registration_session.school,
          uuid: registration_session.uuid
      rescue RegistrationStore::SessionNotFound
        render :session_expired
      rescue RegistrationSession::StepNotFound, RegistrationSession::NotCompletedError
        @current_registration = registration_session
        redirect_to next_step_path
      end

    private

      def cancellation_url(placement_request)
        candidates_cancel_url(placement_request.token)
      end

      def placement_url(placement_request)
        schools_placement_request_url(placement_request)
      end
    end
  end
end
