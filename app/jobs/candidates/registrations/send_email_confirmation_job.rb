module Candidates
  module Registrations
    class SendEmailConfirmationJob < ApplicationJob
      queue_as :default

      retry_on Notify::RetryableError, wait: A_DECENT_AMOUNT_LONGER, attempts: 5

      def perform(uuid)
        registration_session = RegistrationStore.instance.retrieve! uuid

        notification = NotifyEmail::CandidateMagicLink.new \
          to: registration_session.email,
          school_name: registration_session.school.name,
          confirmation_link: confirmation_link(uuid, registration_session)

        notification.despatch!
      end

    private

      def confirmation_link(uuid, registration_session)
        Rails.application.routes.url_helpers
          .candidates_school_registrations_placement_request_new_url \
            registration_session.school,
            uuid: uuid
      end
    end
  end
end
