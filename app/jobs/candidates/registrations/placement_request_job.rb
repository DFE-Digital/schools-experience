module Candidates
  module Registrations
    class PlacementRequestJob < ApplicationJob
      queue_as :default

      def perform(uuid, cancellation_url, placement_request_url)
        registration_session = RegistrationStore.instance.retrieve! uuid
        application_preview  = ApplicationPreview.new registration_session

        NotifyEmail::SchoolRequestConfirmationLinkOnly.new(
          to: registration_session.school.notification_emails,
          school_name: registration_session.school_name,
          placement_request_url: placement_request_url
        ).despatch_later!

        NotifyEmail::CandidateRequestConfirmationNoPii.from_application_preview(
          registration_session.email,
          application_preview,
          cancellation_url
        ).despatch_later!

        RegistrationStore.instance.delete! registration_session.uuid
      end
    end
  end
end
