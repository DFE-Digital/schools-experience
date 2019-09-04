module Candidates
  module Registrations
    class PlacementRequestJob < ApplicationJob
      queue_as :default

      def perform(uuid, cancellation_url, placement_request_url)
        registration_session = RegistrationStore.instance.retrieve! uuid
        application_preview  = ApplicationPreview.new registration_session

        if Rails.application.config.x.phase >= 4
          NotifyEmail::SchoolRequestConfirmationWithPlacementRequestUrl.from_application_preview(
            registration_session.school.notification_emails,
            application_preview,
            placement_request_url
          ).despatch_later!

          NotifyEmail::CandidateRequestConfirmationWithConfirmationLink.from_application_preview(
            registration_session.email,
            application_preview,
            cancellation_url
          ).despatch_later!
        else
          NotifyEmail::SchoolRequestConfirmation.from_application_preview(
            registration_session.school.notification_emails,
            application_preview,
          ).despatch_later!

          NotifyEmail::CandidateRequestConfirmation.from_application_preview(
            registration_session.email,
            application_preview
          ).despatch_later!
        end

        RegistrationStore.instance.delete! registration_session.uuid
      end
    end
  end
end
