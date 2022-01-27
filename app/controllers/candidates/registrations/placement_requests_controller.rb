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
          self.current_candidate = Bookings::Candidate.create_or_update_from_registration_session! \
            registration_session,
            current_contact

          placement_request = current_candidate.placement_requests.create_from_registration_session! \
            registration_session

          Bookings::Gitis::SchoolExperience.from_placement_request(placement_request, :requested)
            .write_to_gitis_contact(current_candidate.gitis_uuid)

          registration_session.flag_as_completed!

          RegistrationStore.instance.store! registration_session

          PlacementRequestJob.perform_later \
            registration_session.uuid,
            cancellation_url(placement_request),
            placement_url(placement_request)
        end

        redirect_to candidates_school_registrations_placement_request_path \
          registration_session.school,
          uuid: registration_session.uuid
      rescue RegistrationStore::SessionNotFound
        render :session_expired
      rescue RegistrationSession::StepNotFound
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
