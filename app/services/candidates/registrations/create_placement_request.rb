module Candidates
  module Registrations
    class CreatePlacementRequest
      attr_reader :placement_request_id, :registration_uuid, :gitis_contact_id

      def initialize(placement_request_id, registration_uuid, gitis_contact_id, host)
        @placement_request_id = placement_request_id
        @registration_uuid = registration_uuid
        @contact_id = gitis_contact_id
        @host = host
      end

      def create!
        send_school_confirmation_email
        send_candidate_confirmation_email
        remove_registration_from_store

        accept_privacy_policy
        log_request_to_gitis_contact
      end

    private

      def registration_session
        @registration_session ||= RegistrationStore.instance.retrieve! registration_uuid
      end

      def application_preview
        @application_preview ||= ApplicationPreview.new registration_session
      end

      def placement_request
        @placement_request ||= Bookings::PlacementRequest.find placement_request_id
      end

      def routes
        Rails.application.routes.url_helpers
      end

      def cancellation_url
        routes.candidates_cancel_url placement_request.token, host: @host
      end

      def placement_request_url
        routes.schools_placement_request_url placement_request, host: @host
      end

      def send_school_confirmation_email
        NotifyEmail::SchoolRequestConfirmationLinkOnly.new(
          to: registration_session.school.notification_emails,
          school_name: registration_session.school_name,
          placement_request_url: placement_request_url
        ).despatch_later!
      end

      def send_candidate_confirmation_email
        NotifyEmail::CandidateRequestConfirmationWithConfirmationLink.
          from_application_preview(
            registration_session.email,
            application_preview,
            cancellation_url
          ).despatch_later!
      end

      def remove_registration_from_store
        RegistrationStore.instance.delete! registration_uuid
      end

      def accept_privacy_policy
        return if Bookings::Gitis::PrivacyPolicy.default.nil?

        AcceptPrivacyPolicyJob.perform_later \
          gitis_contact_id,
          Bookings::Gitis::PrivacyPolicy.default
      end

      def log_request_to_gitis_contact
        Bookings::Gitis::EventLogger.write_later \
          gitis_contact_id, :request, placement_request
      end
    end
  end
end
