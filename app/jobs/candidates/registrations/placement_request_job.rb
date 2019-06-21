module Candidates
  module Registrations
    class PlacementRequestJob < ApplicationJob
      queue_as :default

      retry_on Notify::RetryableError, wait: A_DECENT_AMOUNT_LONGER, attempts: 5

      def perform(uuid, cancellation_url, placement_request_url)
        registration_session = RegistrationStore.instance.retrieve! uuid
        application_preview  = ApplicationPreview.new registration_session

        NotifyEmail::SchoolRequestConfirmation.from_application_preview(
          registration_session.school.notifications_email,
          application_preview,
          placement_request_url
        ).despatch!

        if Rails.application.config.x.phase > 2
          NotifyEmail::CandidateRequestConfirmationWithConfirmationLink.from_application_preview(
            registration_session.email,
            application_preview,
            cancellation_url
          ).despatch!
        else
          NotifyEmail::CandidateRequestConfirmation.from_application_preview(
            registration_session.email,
            application_preview
          ).despatch!
        end

        RegistrationStore.instance.delete! registration_session.uuid
      end
    end
  end
end
