module Candidates
  module Registrations
    class PlacementRequestsController < RegistrationsController
      def show
        @school_name = Bookings::School.find_by!(urn: params[:school_id]).name
      end

      def create
        registration_session = RegistrationStore.instance.retrieve! params[:uuid]

        unless registration_session.completed?
          placement_request = Bookings::PlacementRequest.create_from_registration_session! \
            registration_session,
            cookies[:analytics_tracking_uuid]

          registration_session.flag_as_completed!

          RegistrationStore.instance.store! registration_session

          PlacementRequestJob.perform_later \
            registration_session.uuid,
            new_candidates_placement_request_cancellation_url(placement_request.token)
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
