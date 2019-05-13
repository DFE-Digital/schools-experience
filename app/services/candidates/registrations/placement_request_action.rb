module Candidates
  module Registrations
    class PlacementRequestAction
      def initialize(uuid)
        @uuid = uuid
      end

      def perform!
        school_request_confirmation.despatch!
        candidate_request_confirmation.despatch!
        Bookings::PlacementRequest.create_from_registration_session! \
          registration_session

        RegistrationStore.instance.delete! registration_session.uuid
      end

    private

      def school_request_confirmation
        NotifyEmail::SchoolRequestConfirmation.from_application_preview \
          school_contact_email,
          application_preview
      end

      def candidate_request_confirmation
        NotifyEmail::CandidateRequestConfirmation.from_application_preview \
          candidate_email,
          application_preview
      end

      def registration_session
        @registration_session ||= RegistrationStore.instance.retrieve! @uuid
      end

      def application_preview
        @application_preview ||= ApplicationPreview.new registration_session
      end

      def school_contact_email
        if registration_session.school.profile &&
            registration_session.school.profile.admin_contact_email.present?

          registration_session.school.profile.admin_contact_email
        else
          registration_session.school.contact_email
        end
      end

      def candidate_email
        registration_session.email
      end
    end
  end
end
