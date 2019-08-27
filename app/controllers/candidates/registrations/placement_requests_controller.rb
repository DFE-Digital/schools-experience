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
          if gitis_integration?
            self.current_candidate = Bookings::Candidate.create_or_update_from_registration_session! \
              gitis_crm,
              registration_session,
              current_contact

            placement_request = current_candidate.placement_requests.create_from_registration_session! \
              registration_session,
              cookies[:analytics_tracking_uuid],
              context: :returning_from_confirmation_email

            Bookings::Gitis::EventLogger.write_later \
              current_candidate.gitis_uuid, :request, placement_request
          else
            placement_request = Bookings::PlacementRequest.create_from_registration_session! \
              registration_session,
              cookies[:analytics_tracking_uuid],
              context: :returning_from_confirmation_email
          end

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
        if Rails.application.config.x.phase >= 4
          candidates_cancel_url(placement_request.token)
        else
          ''
        end
      end

      def placement_url(placement_request)
        if Rails.application.config.x.phase >= 4
          schools_placement_request_url(placement_request)
        else
          ''
        end
      end
    end
  end
end
