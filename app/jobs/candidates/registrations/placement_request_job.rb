module Candidates
  module Registrations
    class PlacementRequestJob < ApplicationJob
      queue_as :default

      retry_on Notify::RetryableError, wait: A_DECENT_AMOUNT_LONGER, attempts: 5

      def perform(uuid)
        registration_session = RegistrationStore.instance.retrieve! uuid
        application_preview  = ApplicationPreview.new registration_session

        NotifyEmail::SchoolRequestConfirmation.from_application_preview(
          registration_session.school.notifications_email,
          application_preview
        ).despatch!

        NotifyEmail::CandidateRequestConfirmation.from_application_preview(
          registration_session.email,
          application_preview
        ).despatch!

        RegistrationStore.instance.delete! registration_session.uuid
      end
    end
  end
end
